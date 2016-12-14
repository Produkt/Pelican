//
//  Unrarer.swift
//  Pelican
//
//  Created by Daniel Garcia on 10/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Result
import unrarkit

public struct RarFileInfo: FileInfo {

    public let fileName: String
    public let fileCRC: Int
    public let index: UInt
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
        } catch (let error) {
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
            let unarchiver = try URKArchive(path: sourcePath)
            let filesInfo = try unarchiver.listFileInfo()
            let rarFilesInfo = filesInfo.enumerated().map({ (index, urkFileInfo) -> RarFileInfo in
                return RarFileInfo(fileName: urkFileInfo.filename,
                                   fileCRC: urkFileInfo.crc,
                                   index: UInt(index))
            })
            return .success(rarFilesInfo)
        }  catch  {
            return .failure(UnpackError())
        }
        return .failure(UnpackError())
    }
}

class Unrarer {

    fileprivate let sourcePath: String
    fileprivate let destinationPath: String?
    private var rarFile: URKArchive?

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

    fileprivate func openRarFile() throws {
        rarFile = try URKArchive(path: sourcePath)
    }

    fileprivate func contentInfo() throws -> [RarFileInfo] {
        let filesInfo = try rarFile!.listFileInfo()
        let rarFilesInfo = filesInfo.enumerated().map({ (index, urkFileInfo) -> RarFileInfo in
            return RarFileInfo(fileName: urkFileInfo.filename,
                               fileCRC: urkFileInfo.crc,
                               index: UInt(index))
        })
        return rarFilesInfo
    }

    fileprivate func extract() throws  {
        try rarFile!.extractFiles(to: destinationPath!, overwrite: true, progress: nil)
    }
}
