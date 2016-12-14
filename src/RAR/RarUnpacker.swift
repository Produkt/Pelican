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
        let allContentUnrarer = AllContentUnrarer(sourcePath: filePath, destinationPath: destinationPath)
        let contentInfoTask = RarUnpackAllContentOperation(allContentUnrarer: allContentUnrarer, completion: completion)
        operationQueue.addOperation(contentInfoTask)
        return contentInfoTask
    }

    @discardableResult
    public func unpack(fileWith fileInfo: RarFileInfo, from filePath: String, completion: @escaping UnpackFileTaskCompletion) -> UnpackTask {
        return RarUnpackSingleFileOperation()
    }

    @discardableResult
    public func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask {
        let contentInfoUnrarer = ContentInfoUnrarer(sourcePath: filePath)
        let contentInfoTask = RarUnpackFilesInfoOperation(contentInfoUnrarer: contentInfoUnrarer, completion: completion)
        operationQueue.addOperation(contentInfoTask)
        return contentInfoTask
    }

    @discardableResult
    public func unpack(fileAt filePath: String, in destinationPath: String) -> UnpackContentResult {
        let allContentUnrarer = AllContentUnrarer(sourcePath: filePath, destinationPath: destinationPath)
        return allContentUnrarer.unrar()
    }

    public func unpack(fileWith fileInfo: RarFileInfo, from filePath: String) -> UnpackFileResult {
        return .failure(UnpackError())
    }

    public func contentInfo(in filePath: String) -> ContentInfoResult {
        let contentInfoUnrarer = ContentInfoUnrarer(sourcePath: filePath)
        return contentInfoUnrarer.unrar()
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

    private let allContentUnrarer: AllContentUnrarer
    private let completion: UnpackContentTaskCompletion

    init(allContentUnrarer: AllContentUnrarer, completion: @escaping UnpackContentTaskCompletion) {
        self.allContentUnrarer = allContentUnrarer
        self.completion = completion
    }

    override func main() {
        super.main()
        let result = allContentUnrarer.unrar()
        completion(result)
    }
}

fileprivate class RarUnpackFilesInfoOperation: Operation, UnpackTask {

    public typealias ContentInfoResult = Result<[RarFileInfo], UnpackError>
    public typealias ContentInfoCompletion = (ContentInfoResult) -> Void

    private let contentInfoUnrarer: ContentInfoUnrarer
    private let completion: ContentInfoCompletion

    init(contentInfoUnrarer: ContentInfoUnrarer, completion: @escaping ContentInfoCompletion) {
        self.contentInfoUnrarer = contentInfoUnrarer
        self.completion = completion
    }

    override func main() {
        super.main()
        let result = contentInfoUnrarer.unrar()
        completion(result)
    }
}
