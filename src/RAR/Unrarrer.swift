//
//  Unrarrer.swift
//  Pelican
//
//  Created by Daniel Garcia on 10/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Result

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
