//
//  Unzipper.swift
//  Pelican
//
//  Created by Daniel Garcia on 10/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import minizip
import Result

public struct ZipFileInfo: FileInfo {

    public let fileName: String
    public let fileCRC: UInt
    public let timestamp: Date
    public let compressedSize: UInt
    public let uncompressedSize: UInt
    public let isDirectory: Bool
    public let index: UInt
}

class AllContentUnzipper: Unzipper {

    init(sourcePath: String, destinationPath: String) {
        super.init(sourcePath: sourcePath, destinationPath: destinationPath)
    }

    func unzip() -> UnpackContentResult {
        let startDate = Date()
        do {
            let unzippedFilesInfo = try unzipAllContent()
            let finishDate = Date()
            return .success(UnpackContentSummary(startDate: startDate, finishDate: finishDate, unpackedFiles: unzippedFilesInfo))
        } catch (let unpackError) {
            return .failure(UnpackError(underlyingError: unpackError))
        }
    }

    private func unzipAllContent() throws -> [ZipFileInfo] {
        var unzippedFilesInfo = [ZipFileInfo]()
        do {
            try openZipFile()
            defer {
                closeZipFile()
            }
            guard let destinationPath = destinationPath else {
                throw UnzipError.RequiredDestinationPathNotDefined
            }
            var thereAreMoreFiles = true
            repeat {
                let unzipResult = unzipCurrentFile(in: destinationPath)
                switch unzipResult {
                case .success(let filePath, let fileInfo):
                    unzippedFilesInfo.append(fileInfo)
                case .failure(let error):
                    throw error
                }
                index += 1
                do {
                    try advanceNextFile()
                } catch { thereAreMoreFiles = false }
            } while thereAreMoreFiles
        } catch(let error) { throw error }
        return unzippedFilesInfo
    }
}

class SingleFileUnzipper: Unzipper {

    fileprivate let fileInfo: ZipFileInfo

    init(fileInfo: ZipFileInfo, sourcePath: String) {
        self.fileInfo = fileInfo
        super.init(sourcePath: sourcePath)
    }

    func unzip() -> UnpackFileResult {
        do {
            let fileContent = try unzipContent(for: fileInfo)
            return .success(fileContent)
        } catch (let unpackError) {
            return .failure(UnpackError(underlyingError: unpackError))
        }
    }

    private func unzipContent(for fileInfo: FileInfo) throws -> Data {
        var fileData: Data! = nil
        do {
            try openZipFile()
            defer {
                closeZipFile()
            }
            try advanceCurrentFile(to: fileInfo)
            fileData = try loadCurrentFileData()
        } catch (let error) { throw error }
        return fileData
    }

    private func loadCurrentFileData() throws -> Data {
        let container = temporaryContainer()
        defer {
            delete(temporaryContainer: container)
        }
        let unzipResult = try unzipCurrentFile(in: container)
        switch unzipResult {
        case .success(let filePath, _):
            guard let fileData = Data.data(contentsOfFile: filePath) else {
                throw UnzipError.UndefinedError(info: "Unable to load unzipped file at path \(filePath)")
            }
            return fileData
        case .failure(let error):
            throw error
        }
    }

    private func temporaryContainer() -> String {
        return NSTemporaryDirectory().appendingPathComponent(NSUUID().uuidString)
    }

    private func delete(temporaryContainer: String) {
        try? fileManager.removeItem(atPath: temporaryContainer)
    }
}

class ContentInfoUnzipper: Unzipper {

    public typealias ContentInfoResult = Result<[ZipFileInfo], UnpackError>
    public typealias ContentInfoCompletion = (ContentInfoResult) -> Void

    init(sourcePath: String) {
        super.init(sourcePath: sourcePath)
    }

    func unzip() -> ContentInfoResult {
        do {
            let contentInfo = try contentFilesInfo()
            return Result.success(contentInfo)
        } catch(let error) {
            return Result.failure(UnpackError(underlyingError: error))
        }
    }

    private func contentFilesInfo() throws -> [ZipFileInfo] {
        var contentFilesInfo = [ZipFileInfo]()
        do {
            try openZipFile()
            defer {
                closeZipFile()
            }
            var thereAreMoreFiles = true
            repeat {
                let fileInfo = try openCurrentFileAndLoadFileInfo()
                contentFilesInfo.append(fileInfo)
                index += 1
                do {
                    try advanceNextFile()
                } catch { thereAreMoreFiles = false }
            } while thereAreMoreFiles
        } catch(let error) { throw error }
        return contentFilesInfo
    }

    private func openCurrentFileAndLoadFileInfo() throws -> ZipFileInfo {
        let openCurrentFileResult = unzOpenCurrentFile(zip)
        guard openCurrentFileResult == UNZ_OK else {
            throw UnzipError.UnableToOpenFile(index: index)
        }
        defer {
            unzCloseCurrentFile(zip)
        }
        guard var fileInfo = currentFileInfo() else {
            throw UnzipError.UnableToReadFileInfo(index: index)
        }
        var zipFileInfo: ZipFileInfo! = nil
        do {
            zipFileInfo = try createAZipFileInfo(from: &fileInfo)
        } catch(let error) { throw error }
        return zipFileInfo
    }
}

class Unzipper {

    fileprivate enum UnzipError: Error {
        case RequiredDestinationPathNotDefined
        case UnableToReadZipFileAttributes
        case UnableToOpenZipFile
        case UnableToOpenFile(index: UInt)
        case UnableToReadFileInfo(index: UInt)
        case UnableToCreateFileContainer(path: String, index: UInt)
        case UnableToWriteFile(path: String, index: UInt)
        case UndefinedError(info: String)
    }

    private struct EOF: Error {

    }

    fileprivate var zip: zipFile?
    fileprivate let sourcePath: String
    fileprivate let destinationPath: String?
    fileprivate let overwrite: Bool = true
    fileprivate let bufferSize: UInt32 = 4096
    fileprivate var buffer: Array<CUnsignedChar>
    fileprivate let fileManager = FileManager.default
    fileprivate var index: UInt = 0

    private init() {
        // This init is never used. 
        // Is here just to avoid direct instantiation and get a similar effect of an abtract class
        self.sourcePath = ""
        self.destinationPath = ""
        self.buffer = Array<CUnsignedChar>(repeating: 0, count: Int(bufferSize))
    }

    fileprivate init(sourcePath: String, destinationPath: String? = nil) {
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
        self.buffer = Array<CUnsignedChar>(repeating: 0, count: Int(bufferSize))
    }

    fileprivate func unzipCurrentFile(in destinationPath: String) -> Result<(filePath: String, fileInfo: ZipFileInfo), UnzipError> {
        let openCurrentFileResult = unzOpenCurrentFile(zip)
        guard openCurrentFileResult == UNZ_OK else {
            return .failure(UnzipError.UnableToOpenFile(index: index))
        }
        defer {
            unzCloseCurrentFile(zip)
        }
        guard var fileInfo = currentFileInfo() else {
            return .failure(UnzipError.UnableToReadFileInfo(index: index))
        }
        let fullPath = destinationPath.appendingPathComponent(fileName(from: &fileInfo))
        var zipFileInfo: ZipFileInfo!
        do {
            zipFileInfo = try createAZipFileInfo(from: &fileInfo)
        } catch (let error) {
            return .failure(error as! UnzipError)
        }
        let isDirectory = caclculateIfIsDirectory(fileInfo)
        guard fileManager.fileExists(atPath: fullPath) == false || isDirectory || overwrite else {
            return .success((filePath: fullPath, fileInfo: zipFileInfo as ZipFileInfo))
        }
        do {
            try createEnclosingFolder(for: fullPath, isDirectory: isDirectory, at: index)
        } catch {
            return .failure(UnzipError.UnableToCreateFileContainer(path: fullPath, index: index))
        }
        writeCurrentFile(at: fullPath)
        return .success((filePath: fullPath, fileInfo: zipFileInfo as ZipFileInfo))
    }

    fileprivate func advanceNextFile() throws {
        let cursorResult = unzGoToNextFile(zip)
        guard cursorResult == UNZ_OK && cursorResult != UNZ_END_OF_LIST_OF_FILE else {
            throw EOF()
        }
    }

    fileprivate func advanceCurrentFile(to fileInfo: FileInfo) throws {
        index = 0
        unzGoToFirstFile(zip)
        while index < fileInfo.index {
            let cursorResult = unzGoToNextFile(zip)
            index += 1
            guard cursorResult == UNZ_OK else { throw UnzipError.UnableToOpenFile(index: index) }
        }
    }

    fileprivate func openZipFile() throws {
        zip = unzOpen((sourcePath as NSString).utf8String)
        var globalInfo: unz_global_info = unz_global_info()
        unzGetGlobalInfo(zip, &globalInfo)

        var fileAttributes:[FileAttributeKey : Any]! = nil
        do {
            fileAttributes = try fileManager.attributesOfItem(atPath: sourcePath)
        } catch { throw UnzipError.UnableToReadZipFileAttributes }

        let fileSize: UInt64 = (fileAttributes[FileAttributeKey.size] as! NSNumber).uint64Value
        let currentPosition: UInt64 = 0

        var openFirstFileResult = unzGoToFirstFile(zip)
        guard openFirstFileResult == UNZ_OK else { throw UnzipError.UnableToOpenZipFile }
    }

    fileprivate func currentFileInfo() -> unz_file_info? {
        var fileInfo = unz_file_info()
        memset(&fileInfo, 0, MemoryLayout<unz_file_info>.size)
        let getFileInfoResult = unzGetCurrentFileInfo(zip, &fileInfo, nil, 0, nil, 0, nil, 0)
        guard getFileInfoResult == UNZ_OK else { return nil }
        return fileInfo
    }

    fileprivate func createEnclosingFolder(for path: String, isDirectory: Bool, at index: UInt) throws {
        let creationDate = Date()
        let directoryAttributes = [FileAttributeKey.creationDate.rawValue : creationDate,
                                   FileAttributeKey.modificationDate.rawValue : creationDate]
        let folderToCreate = isDirectory ? path : path.deletingLastPathComponent

        try fileManager.createDirectory(atPath: folderToCreate, withIntermediateDirectories: true, attributes: directoryAttributes)
    }

    fileprivate func caclculateIfIsDirectory(_ fileInfo: unz_file_info) -> Bool {
        let fileNameSize = Int(fileInfo.size_filename) + 1
        let fileName = UnsafeMutablePointer<CChar>.allocate(capacity: fileNameSize)
        defer {
            free(fileName)
        }
        var isDirectory = false
        let fileInfoSizeFileName = Int(fileInfo.size_filename) - 1
        if fileName[fileInfoSizeFileName] == "/".cString(using: String.Encoding.utf8)?.first ||
            fileName[fileInfoSizeFileName] == "\\".cString(using: String.Encoding.utf8)?.first {
            isDirectory = true;
        }
        return isDirectory
    }

    fileprivate func fileName(from fileInfo: inout unz_file_info) -> String {
        let fileNameSize = Int(fileInfo.size_filename) + 1
        let fileName = UnsafeMutablePointer<CChar>.allocate(capacity: fileNameSize)
        defer {
            free(fileName)
        }
        unzGetCurrentFileInfo(zip, &fileInfo, fileName, UInt(fileNameSize), nil, 0, nil, 0)
        fileName[Int(fileInfo.size_filename)] = 0
        return String(cString: fileName)
    }

    fileprivate func createAZipFileInfo(from unzFileInfo: inout unz_file_info) throws -> ZipFileInfo {
        let isDirectory = caclculateIfIsDirectory(unzFileInfo)
        let fileInfoName = fileName(from: &unzFileInfo)
        let fileInfoDate = Date.date(MSDOSFormat: UInt32(unzFileInfo.dosDate))
        let zipFileInfo = ZipFileInfo(fileName: fileInfoName,
                                      fileCRC: Int(unzFileInfo.crc),
                                      timestamp: fileInfoDate,
                                      compressedSize: unzFileInfo.compressed_size,
                                      uncompressedSize: unzFileInfo.uncompressed_size,
                                      isDirectory: isDirectory,
                                      index: index)
        return zipFileInfo
    }

    fileprivate func writeCurrentFile(at path: String) {
        var filePointer: UnsafeMutablePointer<FILE>?
        filePointer = fopen(path, "wb")
        defer {
            fclose(filePointer)
        }
        while filePointer != nil {
            let readBytes = unzReadCurrentFile(zip, &buffer, bufferSize)
            if readBytes > 0 {
                fwrite(buffer, Int(readBytes), 1, filePointer)
            } else {
                break
            }
        }
    }
    
    fileprivate func closeZipFile() {
        unzClose(zip)
    }
}
