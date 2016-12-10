//
//  ZipUnpacker.swift
//  Pelican
//
//  Created by Daniel Garcia on 08/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Foundation
import Result

public typealias ContentInfoResult = Result<[ZipFileInfo], UnpackError>
public typealias ContentInfoCompletion = (ContentInfoResult) -> Void

public class ZipUnpacker: Unpacker {

    public let operationQueue: OperationQueue

    init(operationQueue: OperationQueue) {
        self.operationQueue = operationQueue
    }

    @discardableResult
    public func unpack(fileAt filePath: String, in destinationPath: String, completion: @escaping UnpackContentTaskCompletion) -> UnpackTask {
        let allContentUnzipper = AllContentUnzipper(sourcePath: filePath, destinationPath: destinationPath)
        let unzipTask = ZipUnpackAllContentOperation(allContentUnzipper: allContentUnzipper, completion: completion)
        operationQueue.addOperation(unzipTask)
        return unzipTask
    }

    @discardableResult
    public func unpack(fileWith fileInfo: ZipFileInfo, from filePath: String, completion: @escaping UnpackFileTaskCompletion) -> UnpackTask {
        let singleFileUnzipper = SingleFileUnzipper(fileInfo: fileInfo, sourcePath: filePath)
        let unzipFileTask = ZipUnpackSingleFileOperation(singleFileUnzipper: singleFileUnzipper, completion: completion)
        operationQueue.addOperation(unzipFileTask)
        return unzipFileTask
    }

    @discardableResult
    public func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask {
        let contentInfoUnzipper = ContentInfoUnzipper(sourcePath: filePath)
        let contentInfoTask = ZipUnpackFilesInfoOperation(contentInfoUnzipper: contentInfoUnzipper, completion: completion)
        operationQueue.addOperation(contentInfoTask)
        return contentInfoTask
    }
}

fileprivate class ZipUnpackSingleFileOperation: Operation, UnpackTask {

    private let singleFileUnzipper: SingleFileUnzipper
    private let completion: UnpackFileTaskCompletion

    init(singleFileUnzipper: SingleFileUnzipper, completion: @escaping UnpackFileTaskCompletion) {
        self.singleFileUnzipper = singleFileUnzipper
        self.completion = completion
    }

    override func main() {
        super.main()
        let result = singleFileUnzipper.unzip()
        completion(result)
    }
}

fileprivate class ZipUnpackAllContentOperation: Operation, UnpackTask {

    private let allContentUnzipper: AllContentUnzipper
    private let completion: UnpackContentTaskCompletion

    init(allContentUnzipper: AllContentUnzipper, completion: @escaping UnpackContentTaskCompletion) {
        self.allContentUnzipper = allContentUnzipper
        self.completion = completion
    }

    override func main() {
        super.main()
        let result = allContentUnzipper.unzip()
        completion(result)
    }
}

fileprivate class ZipUnpackFilesInfoOperation: Operation, UnpackTask {

    private let contentInfoUnzipper: ContentInfoUnzipper
    private let completion: ContentInfoCompletion

    init(contentInfoUnzipper: ContentInfoUnzipper, completion: @escaping ContentInfoCompletion) {
        self.contentInfoUnzipper = contentInfoUnzipper
        self.completion = completion
    }

    override func main() {
        super.main()
        let result = contentInfoUnzipper.unzip()
        completion(result)
    }
}
