//
//  Pelican.swift
//  Pelican
//
//  Created by Daniel Garcia on 06/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Result

public enum PelicanFormat: String {
    case ZIP
    case RAR
}

public enum PelicanType: String {
    case packer
    case unpacker
}

open class Pelican {

    open static func zipUnpacker(operationQueue: OperationQueue? = nil) -> ZipUnpacker {
        return ZipUnpacker(operationQueue: operationQueue ?? buildOperationQueue(type: .unpacker, format: .ZIP))
    }

    open static func zipPacker(operationQueue: OperationQueue? = nil) -> ZipPacker {
        return ZipPacker(operationQueue: operationQueue ?? buildOperationQueue(type: .packer, format: .ZIP))
    }

    private static func buildOperationQueue(type: PelicanType, format: PelicanFormat) -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.name = "com.pelican.\(type.rawValue)-\(format.rawValue)-\(Date().timeIntervalSince1970)"
        return operationQueue
    }
}

// MARK: Packing

public struct PackError: Error {

}

public typealias PackTaskCompletion = (Result<Void, PackError>) -> Void

public protocol Packer {

    @discardableResult
    func pack(files filePaths: [String], in filePath: String, completion: @escaping PackTaskCompletion) -> PackTask
}

public protocol PackTask {
    func cancel()
}

// MARK: Unpacking

public struct UnpackError: Error {
    let underlyingError: Error
}

public struct UnpackContentSummary {
    public let startDate: Date
    public let finishDate: Date
    public let unpackedFiles: [FileInfo]
}

public typealias UnpackContentResult = Result<UnpackContentSummary, UnpackError>
public typealias UnpackContentTaskCompletion = (UnpackContentResult) -> Void
public typealias UnpackFileResult = Result<Data, UnpackError>
public typealias UnpackFileTaskCompletion = (UnpackFileResult) -> Void

public protocol Unpacker {

    associatedtype FileInfoType
    typealias ContentInfoResult = Result<[FileInfoType], UnpackError>
    typealias ContentInfoCompletion = (ContentInfoResult) -> Void

    @discardableResult
    func unpack(fileAt filePath: String, in destinationPath: String, completion: @escaping UnpackContentTaskCompletion) -> UnpackTask
    func unpack(fileAt filePath: String, in destinationPath: String) -> UnpackContentResult
    @discardableResult
    func unpack(fileWith fileInfo: FileInfoType, from filePath: String, completion: @escaping UnpackFileTaskCompletion) -> UnpackTask
    func unpack(fileWith fileInfo: FileInfoType, from filePath: String) -> UnpackFileResult
    @discardableResult
    func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask
    func contentInfo(in filePath: String) -> ContentInfoResult
}

public protocol UnpackTask {
    func cancel()
}

// MARK: File Info

public protocol FileInfo {
    var fileName: String { get }
    var fileCRC: Int { get }
    var index: UInt { get }
}
