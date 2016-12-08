//
//  ZipUnpacker.swift
//  Pelican
//
//  Created by Daniel Garcia on 08/12/2016.
//
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
}

class ZipUnpackOperation: Operation, UnpackTask {

    private let destinationPath: String
    private var zip: zipFile?
    private let chunkSize: Int = 16384

    init(destinationPath: String) {
        self.destinationPath = destinationPath
    }

    override func main() {
        super.main()

    }
}

class ZipUnpackContentInfoOperation: Operation, UnpackTask {

    private let sourcePath: String
    private var zip: zipFile?
    private let completion: ContentInfoCompletion


    init(sourcePath: String, completion: @escaping ContentInfoCompletion) {
        self.sourcePath = sourcePath
        self.completion = completion
    }

    override func main() {
        super.main()
        guard let contentInfoResult = contentInfo() else {
            completion(Result.failure(UnpackError()))
            return
        }
        completion(Result.success(contentInfoResult))
    }

    private func contentInfo() -> [FileInfo]? {
        zip = unzOpen((sourcePath as NSString).utf8String)
        var globalInfo: unz_global_info = unz_global_info()
        unzGetGlobalInfo(zip, &globalInfo)
        var cursorResult = unzGoToFirstFile(zip)
        guard cursorResult == UNZ_OK else { return nil }
        var index: UInt = 0
        var contentInfo = [FileInfo]()
        repeat {
            cursorResult = unzOpenCurrentFile(zip)
            guard cursorResult == UNZ_OK else { break }

            var unzFileInfo: unz_file_info = unz_file_info()
            memset(&unzFileInfo, 0, MemoryLayout<unz_file_info>.size)
            cursorResult = unzGetCurrentFileInfo(zip, &unzFileInfo, nil, 0, nil, 0, nil, 0)
            unzCloseCurrentFile(zip)
            if let fileInfo = fileInfo(from: &unzFileInfo, at: index) {
                contentInfo.append(fileInfo)
            }
            cursorResult = unzGoToNextFile(zip)
            index += 1
        } while cursorResult == UNZ_OK && cursorResult != UNZ_END_OF_LIST_OF_FILE
        unzClose(zip)
        return contentInfo
    }

    private func fileInfo(from unzFileInfo: inout unz_file_info, at index: UInt) -> FileInfo? {
        let fileNameSize = Int(unzFileInfo.size_filename) + 1
        let fileName = UnsafeMutablePointer<CChar>.allocate(capacity: fileNameSize)
        unzGetCurrentFileInfo(zip, &unzFileInfo, fileName, uLong(fileNameSize), nil, 0, nil, 0)
        fileName[Int(unzFileInfo.size_filename)] = 0

        let isDirectory = (fileName[Int(unzFileInfo.size_filename) - 1] == "/".cString(using: String.Encoding.utf8)?.first ||
            fileName[Int(unzFileInfo.size_filename) - 1] == "\\".cString(using: String.Encoding.utf8)?.first)

        guard let fileInfoName = String(utf8String: fileName),
            let fileInfoDate = Date.date(MSDOSFormat: UInt32(unzFileInfo.dosDate)) else { return nil }

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
