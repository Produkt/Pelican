//
//  ZipUnpacker.swift
//  Pelican
//
//  Created by Daniel Garcia on 08/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Foundation
import minizip
import Result

public class ZipUnpacker: Unpacker {
    public let operationQueue: OperationQueue

    init(operationQueue: OperationQueue) {
        self.operationQueue = operationQueue
    }

    public func unpack(fileAt filePath: String, in destinationPath: String, completion: @escaping UnpackTaskCompletion) -> UnpackTask {
        let unzipTask = ZipUnpackAllContentOperation(sourcePath: filePath, destinationPath: destinationPath, completion: completion)
        operationQueue.addOperation(unzipTask)
        return unzipTask
    }

    public func unpack(fileWith fileInfo: FileInfo, from filePath: String, in destinationPath: String, completion: @escaping UnpackTaskCompletion) -> UnpackTask {
        let unzipFileTask = ZipUnpackSingleFileOperation(fileInfo: fileInfo, sourcePath: filePath, destinationPath: destinationPath, completion: completion)
        operationQueue.addOperation(unzipFileTask)
        return unzipFileTask
    }

    public func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask {
        let contentInfoTask = ZipUnpackFilesInfoOperation(sourcePath: filePath, completion: completion)
        operationQueue.addOperation(contentInfoTask)
        return contentInfoTask
    }
}

class ZipUnpackSingleFileOperation: ZipUnpackOperation {

    fileprivate let fileInfo: FileInfo
    fileprivate let completion: UnpackTaskCompletion

    init(fileInfo: FileInfo, sourcePath: String, destinationPath: String?, completion: @escaping UnpackTaskCompletion) {
        self.fileInfo = fileInfo
        self.completion = completion
        super.init(sourcePath: sourcePath, destinationPath: destinationPath)
    }

    override func main() {
        super.main()
        do {
            try unzipContent(for: fileInfo)
            completion(.success())
        } catch (let unpackError) {
            completion(.failure(UnpackError(underlyingError: unpackError)))
        }
    }

    private func unzipContent(for fileInfo: FileInfo) throws {
        do {
            try openZipFile()
            defer {
                closeZipFile()
            }
            try advanceCurrentFileFromBegining(to: fileInfo)
            try unzipCurrentFile()
        } catch (let error) { throw error }
    }
}

class ZipUnpackAllContentOperation: ZipUnpackOperation {

    fileprivate let completion: UnpackTaskCompletion

    init(sourcePath: String, destinationPath: String?, completion: @escaping UnpackTaskCompletion) {
        self.completion = completion
        super.init(sourcePath: sourcePath, destinationPath: destinationPath)
    }

    override func main() {
        super.main()
        do {
            try unzipAllContent()
            completion(.success())
        } catch (let unpackError) {
            completion(.failure(UnpackError(underlyingError: unpackError)))
        }
    }

    fileprivate func unzipAllContent() throws {
        do {
            try openZipFile()
            defer {
                closeZipFile()
            }
            var thereAreMoreFiles = true
            repeat {
                try unzipCurrentFile()
                index += 1
                do {
                    try advanceNextFile()
                } catch { thereAreMoreFiles = false }
            } while thereAreMoreFiles
        } catch(let error) { throw error }
    }
}

class ZipUnpackFilesInfoOperation: ZipUnpackOperation {

    private let completion: ContentInfoCompletion

    init(sourcePath: String, completion: @escaping ContentInfoCompletion) {
        self.completion = completion
        super.init(sourcePath: sourcePath)
    }

    override func main() {
        super.main()
        do {
            let contentInfo = try contentFilesInfo()
            completion(Result.success(contentInfo))
        } catch(let error) {
            completion(Result.failure(UnpackError(underlyingError: error)))
        }
    }

    func contentFilesInfo() throws -> [FileInfo] {
        var contentFilesInfo = [FileInfo]()
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

    private func openCurrentFileAndLoadFileInfo() throws -> FileInfo {
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
        var zipFileInfo: FileInfo! = nil
        do {
            zipFileInfo = try createAZipFileInfo(from: &fileInfo)
        } catch(let error) { throw error }
        return zipFileInfo
    }
}

class ZipUnpackOperation: Operation, UnpackTask {

    fileprivate enum UnzipError: Error {
        case RequiredDestinationPathNotDefined
        case UnableToReadZipFileAttributes
        case UnableToOpenZipFile
        case UnableToOpenFile(index: UInt)
        case UnableToReadFileInfo(index: UInt)
        case UnableToCreateFileContainer(path: String, index: UInt)
        case UnableToWriteFile(path: String, index: UInt)
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

    init(sourcePath: String, destinationPath: String? = nil) {
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
        self.buffer = Array<CUnsignedChar>(repeating: 0, count: Int(bufferSize))
    }

    fileprivate func unzipCurrentFile() throws {
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
        guard let destinationPath = destinationPath else {
            throw UnzipError.RequiredDestinationPathNotDefined
        }
        let fullPath = destinationPath.appendingPathComponent(fileName(from: &fileInfo))
        let isDirectory = caclculateIfIsDirectory(fileInfo)
        guard fileManager.fileExists(atPath: fullPath) == false || isDirectory || overwrite else {
            return
        }
        do {
            try createEnclosingFolder(for: fullPath, isDirectory: isDirectory, at: index)
        } catch { throw UnzipError.UnableToCreateFileContainer(path: fullPath, index: index) }

        writeCurrentFile(at: fullPath)
    }

    fileprivate func advanceNextFile() throws {
        let cursorResult = unzGoToNextFile(zip)
        guard cursorResult == UNZ_OK && cursorResult != UNZ_END_OF_LIST_OF_FILE else {
            throw EOF()
        }
    }

    fileprivate func advanceCurrentFileFromBegining(to fileInfo: FileInfo) throws {
        index = 0
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
        let fileInfoSizeFileName = Int(fileInfo.size_filename-1)
        if (fileName[fileInfoSizeFileName] == "/".cString(using: String.Encoding.utf8)?.first ||
            fileName[fileInfoSizeFileName] == "\\".cString(using: String.Encoding.utf8)?.first) {
            isDirectory = true;
        }
        return isDirectory
    }

    func fileName(from fileInfo: inout unz_file_info) -> String {
        let fileNameSize = Int(fileInfo.size_filename) + 1
        let fileName = UnsafeMutablePointer<CChar>.allocate(capacity: fileNameSize)
        defer {
            free(fileName)
        }
        unzGetCurrentFileInfo(zip, &fileInfo, fileName, UInt(fileNameSize), nil, 0, nil, 0)
        fileName[Int(fileInfo.size_filename)] = 0
        return String(cString: fileName)
    }

    fileprivate func createAZipFileInfo(from unzFileInfo: inout unz_file_info) throws -> FileInfo {
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

public struct ZipFileInfo: FileInfo {

    public let fileName: String
    public let fileCRC: Int
    public let timestamp: Date
    public let compressedSize: UInt
    public let uncompressedSize: UInt
    public let isDirectory: Bool
    public let index: UInt
}

extension Date {

    // Format from http://newsgroups.derkeiler.com/Archive/Comp/comp.os.msdos.programmer/2009-04/msg00060.html
    // Two consecutive words, or a longword, YYYYYYYMMMMDDDDD hhhhhmmmmmmsssss
    // YYYYYYY is years from 1980 = 0
    // sssss is (seconds/2).
    //
    // 3658 = 0011 0110 0101 1000 = 0011011 0010 11000 = 27 2 24 = 2007-02-24
    // 7423 = 0111 0100 0010 0011 - 01110 100001 00011 = 14 33 2 = 14:33:06

    static let kYearMask: UInt32 = 0xFE000000;
    static let kMonthMask: UInt32 = 0x1E00000;
    static let kDayMask: UInt32 = 0x1F0000;
    static let kHourMask: UInt32 = 0xF800;
    static let kMinuteMask: UInt32 = 0x7E0;
    static let kSecondMask: UInt32 = 0x1F;

    static let gregorianCalendar: NSCalendar = {
        return NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
    }()

    static func date(MSDOSFormat: UInt32) -> Date {
        var components = DateComponents()
        components.year = Int(UInt32(1980) + ((MSDOSFormat & kYearMask) >> 25))
        components.month = Int((MSDOSFormat & kMonthMask) >> 21)
        components.day = Int((MSDOSFormat & kDayMask) >> 16)
        components.hour = Int((MSDOSFormat & kHourMask) >> 11)
        components.minute = Int((MSDOSFormat & kMinuteMask) >> 5)
        components.second = Int((MSDOSFormat & kSecondMask) * 2)
        let dateFromComponents = gregorianCalendar.date(from: components)!
        return Date(timeInterval: 0, since: dateFromComponents)
    }
}
