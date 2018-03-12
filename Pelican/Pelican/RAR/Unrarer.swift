//
//  Unrarer.swift
//  Pelican
//
//  Created by Daniel Garcia on 10/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Foundation
import UIKit
import UnrarKit

class SingleFileUnrarer: Unrarer {

    let fileInfo: RarFileInfo

    init(sourcePath: String, fileInfo: RarFileInfo) {
        self.fileInfo = fileInfo
        super.init(sourcePath: sourcePath, destinationPath: nil)
    }

    func unrar() -> UnpackFileResult {
        do {
            try openRarFile()
            let fileData = try extractFile(with: fileInfo)
            return .success(fileData)
        } catch {
            return .failure(UnpackError())
        }
    }
}

class AllContentUnrarer: Unrarer {

    init(sourcePath: String, destinationPath: String) {
        super.init(sourcePath: sourcePath, destinationPath: destinationPath)
    }

    func unrar() -> UnpackContentResult {
        do {
            let startDate = Date()
            try openRarFile()
            let rarFilesInfo = try contentInfo()
            try extract()
            let finishDate = Date()
            let summary = UnpackContentSummary(startDate: startDate, finishDate: finishDate, unpackedFiles: rarFilesInfo)
            return .success(summary)
        } catch {
            return .failure(UnpackError())
        }
    }
}

class ContentInfoUnrarer: Unrarer {

    public typealias ContentInfoResult = Result<[RarFileInfo], UnpackError>
    public typealias ContentInfoCompletion = (ContentInfoResult) -> Void

    init(sourcePath: String) {
        super.init(sourcePath: sourcePath)
    }

    func unrar() -> ContentInfoResult {
        do {
            let rarFilesInfo = try contentInfo()
            return .success(rarFilesInfo)
        }  catch  {
            return .failure(UnpackError())
        }
    }
}

class Unrarer {

    fileprivate let sourcePath: String
    fileprivate let destinationPath: String?

    private init() {
        // This init is never used.
        // Is here just to avoid direct instantiation and get a similar effect of an abtract class
        self.sourcePath = ""
        self.destinationPath = ""
    }

    init(sourcePath: String, destinationPath: String? = nil) {
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath        
    }

    @discardableResult
    fileprivate func openRarFile() throws -> URKArchive {
        return try URKArchive(path: sourcePath)
    }

    fileprivate func contentInfo() throws -> [RarFileInfo] {
        let rarFile = try openRarFile()
        let filesInfo = try rarFile.listFileInfo()
        let rarFilesInfo = filesInfo.enumerated().map({ (index, urkFileInfo) -> RarFileInfo in
            return RarFileInfo(from: urkFileInfo, fileIndex: UInt(index))
        })
        return rarFilesInfo
    }

    fileprivate func extract() throws  {
        let rarFile = try openRarFile()
        try rarFile.extractFiles(to: destinationPath!, overwrite: true, progress: nil)
    }

    fileprivate func extractFile(with fileInfo: RarFileInfo) throws -> Data {
        let rarFile = try openRarFile()
        var fileData = Data()
        var extractionProgress: CGFloat = 0
        repeat {
            try rarFile.extractBufferedData(fromFile: fileInfo.fileName, action: { (dataChunk, progress) -> Void in
                fileData.append(dataChunk)
                extractionProgress = progress
            })
        } while extractionProgress < 1
        return fileData
    }
}

public struct RarFileInfo: FileInfo {

    public let fileName: String
    public let fileCRC: UInt
    public let index: UInt

    public let archiveName: String
    public let timestamp: Date
    public let uncompressedSize: Int64
    public let compressedSize: Int64
    public let isEncryptedWithPassword: Bool
    public let isDirectory: Bool
    public let compressionMethod: RarCompressionMethod
    public let hostOS: RarHostOS

    public enum RarCompressionMethod {

        case storage
        case fastest
        case fast
        case normal
        case good
        case best
    }

    public enum RarHostOS {

        case MSDOS
        case OS2
        case windows
        case unix
        case macOS
        case beOS
    }
}
