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

    public func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask {
        let contentInfoTask = ZipUnpackContentInfoOperation(sourcePath: filePath, completion: completion)
        operationQueue.addOperation(contentInfoTask)
        return contentInfoTask
    }

    public func unpack(fileAt filePath: String, in destinationPath: String, completion: @escaping UnpackTaskCompletion) -> UnpackTask {
        let unzipTask = ZipUnpackOperation(sourcePath: filePath, destinationPath: destinationPath, completion: completion)
        operationQueue.addOperation(unzipTask)
        return unzipTask
    }
}

class ZipUnpackOperation: Operation, UnpackTask {

    enum UnzipError: Error {
        case UnableToReadZipFileAttributes
        case UnableToOpenZipFile
        case UnableToOpenFile(index: UInt)
        case UnableToReadFileInfo(index: UInt)
        case UnableToReadFileName(index: UInt)
        case UnableToCreateFileContainer(path: String, index: UInt)
        case UnableToWriteFile(path: String, index: UInt)
        case UnableToCloseFile(path: String, index: UInt)
    }

    private var zip: zipFile?
    private let sourcePath: String
    private let destinationPath: String
    private let completion: UnpackTaskCompletion
    private let overwrite: Bool = true

    init(sourcePath: String, destinationPath: String, completion: @escaping UnpackTaskCompletion) {
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
        self.completion = completion
    }

    override func main() {
        super.main()
        do {
            try unzip()
            completion(.success())
        } catch (let unpackError) {
            completion(.failure(UnpackError(underlyingError: unpackError)))
        }
    }

    func unzip() throws {
        let fileManager = FileManager.default

        zip = unzOpen((sourcePath as NSString).utf8String)
        var globalInfo: unz_global_info = unz_global_info()
        unzGetGlobalInfo(zip, &globalInfo)

        var fileAttributes:[FileAttributeKey : Any]! = nil
        do {
           fileAttributes = try fileManager.attributesOfItem(atPath: sourcePath)
        } catch { throw UnzipError.UnableToReadZipFileAttributes }
        let fileSize: UInt64 = (fileAttributes[FileAttributeKey.size] as! NSNumber).uint64Value
        let currentPosition: UInt64 = 0

        var cursorResult = unzGoToFirstFile(zip)
        guard cursorResult == UNZ_OK else { throw UnzipError.UnableToOpenZipFile }
        var index: UInt = 0
        var currentFileCursorResult: Int32 = 0
        let bufferSize: UInt32 = 4096
        var buffer = Array<CUnsignedChar>(repeating: 0, count: Int(bufferSize))

        repeat {
            cursorResult = unzOpenCurrentFile(zip)
            guard cursorResult == UNZ_OK else { throw UnzipError.UnableToOpenFile(index: index) }

            var fileInfo = unz_file_info64()
            memset(&fileInfo, 0, MemoryLayout<unz_file_info>.size)
            currentFileCursorResult = unzGetCurrentFileInfo64(zip, &fileInfo, nil, 0, nil, 0, nil, 0)
            if currentFileCursorResult != UNZ_OK {
                unzCloseCurrentFile(zip)
                throw UnzipError.UnableToReadFileInfo(index: index)
            }

            let fileNameSize = Int(fileInfo.size_filename) + 1
            let fileName = UnsafeMutablePointer<CChar>.allocate(capacity: fileNameSize)

            unzGetCurrentFileInfo64(zip, &fileInfo, fileName, UInt(fileNameSize), nil, 0, nil, 0)
            fileName[Int(fileInfo.size_filename)] = 0
            var pathString = String(cString: fileName)

            guard pathString.characters.isEmpty == false else {
                throw UnzipError.UnableToReadFileName(index: index)
            }

            var isDirectory = false
            let fileInfoSizeFileName = Int(fileInfo.size_filename-1)
            if (fileName[fileInfoSizeFileName] == "/".cString(using: String.Encoding.utf8)?.first || fileName[fileInfoSizeFileName] == "\\".cString(using: String.Encoding.utf8)?.first) {
                isDirectory = true;
            }
            free(fileName)
            if pathString.rangeOfCharacter(from: CharacterSet(charactersIn: "/\\")) != nil {
                pathString = pathString.replacingOccurrences(of: "\\", with: "/")
            }

            let fullPath = destinationPath.appendingPathComponent(pathString)

            let creationDate = Date()
            let directoryAttributes = [FileAttributeKey.creationDate.rawValue : creationDate,
                                       FileAttributeKey.modificationDate.rawValue : creationDate]
            do {
                if isDirectory {
                    try fileManager.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: directoryAttributes)
                }
                else {
                    let parentDirectory = (fullPath as NSString).deletingLastPathComponent
                    try fileManager.createDirectory(atPath: parentDirectory, withIntermediateDirectories: true, attributes: directoryAttributes)
                }
            } catch {
                throw UnzipError.UnableToCreateFileContainer(path: fullPath, index: index)
            }
            if fileManager.fileExists(atPath: fullPath) && !isDirectory && !overwrite {
                unzCloseCurrentFile(zip)
                cursorResult = unzGoToNextFile(zip)
            }
            var filePointer: UnsafeMutablePointer<FILE>?
            filePointer = fopen(fullPath, "wb")
            while filePointer != nil {
                let readBytes = unzReadCurrentFile(zip, &buffer, bufferSize)
                if readBytes > 0 {
                    fwrite(buffer, Int(readBytes), 1, filePointer)
                } else {
                    break
                }
            }
            fclose(filePointer)
            currentFileCursorResult = unzCloseCurrentFile(zip)
            if currentFileCursorResult == UNZ_CRCERROR {
                throw UnzipError.UnableToCloseFile(path: fullPath, index: index)
            }
            cursorResult = unzGoToNextFile(zip)

            index += 1
        } while cursorResult == UNZ_OK && cursorResult != UNZ_END_OF_LIST_OF_FILE
        unzClose(zip)
    }
}

class ZipUnpackContentInfoOperation: Operation, UnpackTask {

    enum ContentInfoError: Error {
        case UnableToOpenZipFile
        case UnableToOpenFile(index: UInt)
        case UnableToReadFileName(index: UInt)
        case UnableToReadFileDate(fileName: String, index: UInt)
    }

    private var zip: zipFile?
    private let sourcePath: String
    private let completion: ContentInfoCompletion

    init(sourcePath: String, completion: @escaping ContentInfoCompletion) {
        self.sourcePath = sourcePath
        self.completion = completion
    }

    override func main() {
        super.main()
        do {
            let contentInfoResult = try contentInfo()
            completion(Result.success(contentInfoResult))
        } catch(let error) {
            completion(Result.failure(UnpackError(underlyingError: error)))
        }
    }

    private func contentInfo() throws -> [FileInfo] {
        zip = unzOpen((sourcePath as NSString).utf8String)
        var globalInfo: unz_global_info = unz_global_info()
        unzGetGlobalInfo(zip, &globalInfo)
        var cursorResult = unzGoToFirstFile(zip)
        guard cursorResult == UNZ_OK else { throw ContentInfoError.UnableToOpenZipFile }
        var index: UInt = 0
        var contentInfo = [FileInfo]()
        repeat {
            cursorResult = unzOpenCurrentFile(zip)
            guard cursorResult == UNZ_OK else { throw ContentInfoError.UnableToOpenFile(index: index) }

            var unzFileInfo: unz_file_info = unz_file_info()
            memset(&unzFileInfo, 0, MemoryLayout<unz_file_info>.size)
            cursorResult = unzGetCurrentFileInfo(zip, &unzFileInfo, nil, 0, nil, 0, nil, 0)
            unzCloseCurrentFile(zip)
            do {
                let fileInfoResult = try fileInfo(from: &unzFileInfo, at: index)
                contentInfo.append(fileInfoResult)
            } catch (let error) { throw error }
            cursorResult = unzGoToNextFile(zip)
            index += 1
        } while cursorResult == UNZ_OK && cursorResult != UNZ_END_OF_LIST_OF_FILE
        unzClose(zip)
        return contentInfo
    }

    private func fileInfo(from unzFileInfo: inout unz_file_info, at index: UInt) throws -> FileInfo {
        let fileNameSize = Int(unzFileInfo.size_filename) + 1
        let fileName = UnsafeMutablePointer<CChar>.allocate(capacity: fileNameSize)
        unzGetCurrentFileInfo(zip, &unzFileInfo, fileName, uLong(fileNameSize), nil, 0, nil, 0)
        fileName[Int(unzFileInfo.size_filename)] = 0

        let isDirectory = (fileName[Int(unzFileInfo.size_filename) - 1] == "/".cString(using: String.Encoding.utf8)?.first ||
            fileName[Int(unzFileInfo.size_filename) - 1] == "\\".cString(using: String.Encoding.utf8)?.first)

        guard let fileInfoName = String(utf8String: fileName) else {
            throw ContentInfoError.UnableToReadFileName(index: index)
        }
        guard let fileInfoDate = Date.date(MSDOSFormat: UInt32(unzFileInfo.dosDate)) else { throw ContentInfoError.UnableToReadFileDate(fileName: fileInfoName, index: index) }

        let zipFileInfo = ZipFileInfo(fileName: fileInfoName,
                                      fileCRC: Int(unzFileInfo.crc),
                                      timestamp: fileInfoDate,
                                      compressedSize: unzFileInfo.compressed_size,
                                      uncompressedSize: unzFileInfo.uncompressed_size,
                                      isDirectory: isDirectory,
                                      index: index)
        return zipFileInfo
    }
}

struct ZipFileInfo: FileInfo {
    let fileName: String
    let fileCRC: Int
    let timestamp: Date
    let compressedSize: UInt
    let uncompressedSize: UInt
    let isDirectory: Bool
    let index: UInt
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

    static func date(MSDOSFormat: UInt32) -> Date? {
        var components = DateComponents()
        components.year = Int(UInt32(1980) + ((MSDOSFormat & kYearMask) >> 25))
        components.month = Int((MSDOSFormat & kMonthMask) >> 21)
        components.day = Int((MSDOSFormat & kDayMask) >> 16)
        components.hour = Int((MSDOSFormat & kHourMask) >> 11)
        components.minute = Int((MSDOSFormat & kMinuteMask) >> 5)
        components.second = Int((MSDOSFormat & kSecondMask) * 2)
        guard let dateFromComponents = gregorianCalendar.date(from: components) else { return nil }
        return Date(timeInterval: 0, since: dateFromComponents)
    }
}
