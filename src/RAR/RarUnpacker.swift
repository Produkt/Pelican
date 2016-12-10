//
//  RarUnpacker.swift
//  Pelican
//
//  Created by Daniel Garcia on 08/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Foundation
import Result

public class RarUnpacker: Unpacker {

    public typealias ContentInfoResult = Result<[RarFileInfo], UnpackError>
    public typealias ContentInfoCompletion = (ContentInfoResult) -> Void

    public let operationQueue: OperationQueue

    init(operationQueue: OperationQueue) {
        self.operationQueue = operationQueue
    }

    @discardableResult
    public func unpack(fileAt filePath: String, in destinationPath: String, completion: @escaping UnpackContentTaskCompletion) -> UnpackTask {
        return RarUnpackAllContentOperation()
    }

    @discardableResult
    public func unpack(fileWith fileInfo: RarFileInfo, from filePath: String, completion: @escaping UnpackFileTaskCompletion) -> UnpackTask {
        return RarUnpackSingleFileOperation()
    }

    @discardableResult
    public func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask {
        return RarUnpackFilesInfoOperation()
    }

    @discardableResult
    public func unpack(fileAt filePath: String, in destinationPath: String) -> UnpackContentResult {
        return .failure(UnpackError())
    }

    public func unpack(fileWith fileInfo: RarFileInfo, from filePath: String) -> UnpackFileResult {
        return .failure(UnpackError())
    }

    public func contentInfo(in filePath: String) -> ContentInfoResult {
        let contentInfoUnzipper = ContentInfoUnrarrer(sourcePath: filePath)
        return contentInfoUnzipper.unrar()
    }
}

fileprivate class RarUnpackSingleFileOperation: Operation, UnpackTask {

//    private let singleFileUnzipper: SingleFileUnzipper
//    private let completion: UnpackFileTaskCompletion
//
//    init(singleFileUnzipper: SingleFileUnzipper, completion: @escaping UnpackFileTaskCompletion) {
//        self.singleFileUnzipper = singleFileUnzipper
//        self.completion = completion
//    }
//
//    override func main() {
//        super.main()
//        let result = singleFileUnzipper.unzip()
//        completion(result)
//    }
}

fileprivate class RarUnpackAllContentOperation: Operation, UnpackTask {

//    private let allContentUnzipper: AllContentUnzipper
//    private let completion: UnpackContentTaskCompletion
//
//    init(allContentUnzipper: AllContentUnzipper, completion: @escaping UnpackContentTaskCompletion) {
//        self.allContentUnzipper = allContentUnzipper
//        self.completion = completion
//    }
//
//    override func main() {
//        super.main()
//        let result = allContentUnzipper.unzip()
//        completion(result)
//    }
}

fileprivate class RarUnpackFilesInfoOperation: Operation, UnpackTask {

//    public typealias ContentInfoResult = Result<[RarFileInfo], UnpackError>
//    public typealias ContentInfoCompletion = (ContentInfoResult) -> Void
//
//    private let contentInfoUnzipper: ContentInfoUnzipper
//    private let completion: ContentInfoCompletion
//
//    init(contentInfoUnzipper: ContentInfoUnzipper, completion: @escaping ContentInfoCompletion) {
//        self.contentInfoUnzipper = contentInfoUnzipper
//        self.completion = completion
//    }
//
//    override func main() {
//        super.main()
//        let result = contentInfoUnzipper.unzip()
//        completion(result)
//    }
}
