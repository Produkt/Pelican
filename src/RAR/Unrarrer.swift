//
//  Unrarrer.swift
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

class ContentInfoUnrarrer: Unrarrer {

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

class Unrarrer {

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
}
