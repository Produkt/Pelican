//
//  Pelican.swift
//  Pelican
//
//  Created by Daniel Garcia on 06/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Result

public enum PelicanType: String {
    case ZIP
    case RAR
}

open class Pelican {

    open static func zipUnpacker(operationQueue: OperationQueue? = nil) -> ZipUnpacker {
        return ZipUnpacker(operationQueue: operationQueue ?? buildOperationQueue(for: .ZIP))
    }

    open static func zipPacker(operationQueue: OperationQueue? = nil) -> ZipPacker {
        return ZipPacker(operationQueue: operationQueue ?? buildOperationQueue(for: .ZIP))
    }

    private static func buildOperationQueue(for type: PelicanType) -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.name = "com.produkt.pelican.\(type.rawValue)-queue-\(Date().timeIntervalSince1970)"
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

public typealias UnpackTaskCompletion = (Result<Void, UnpackError>) -> Void

public protocol Unpacker {

    associatedtype FileInfoType
    typealias ContentInfoCompletion = (Result<[FileInfoType], UnpackError>) -> Void

    @discardableResult
    func unpack(fileAt filePath: String, in destinationPath: String, completion: @escaping UnpackTaskCompletion) -> UnpackTask
    @discardableResult
    func unpack(fileWith fileInfo: FileInfoType, from filePath: String, in destinationPath: String, completion: @escaping UnpackTaskCompletion) -> UnpackTask
    @discardableResult
    func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask
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
