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

public typealias PackTaskCompletion = (Result<Void, PackError>) -> Void
public typealias ContentInfoCompletion = (Result<[FileInfo], UnpackError>) -> Void
public typealias UnpackTaskCompletion = (Result<Void, PackError>) -> Void

open class Pelican {

    open static func packer(for type: PelicanType, operationQueue: OperationQueue? = nil) -> Packer? {
        switch type {
        case .ZIP:
            return ZipPacker(operationQueue: operationQueue ?? buildOperationQueue(for: type))
        case .RAR:
            // As RAR is a proprietary format, we cant pack. Only unpack
            return nil
        }
    }
    
    open static func unpacker(for type: PelicanType, operationQueue: OperationQueue? = nil) -> Unpacker? {
        switch type {
        case .ZIP:
            return ZipUnpacker(operationQueue: operationQueue ?? buildOperationQueue(for: type))
        case .RAR:
            return nil
        }
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

public protocol Packer {
    @discardableResult
    func pack(files filePaths: [String], in filePath: String, completion: @escaping PackTaskCompletion) -> PackTask
}

public protocol PackTask {
    func cancel()
}

// MARK: Unpacking

public struct UnpackError: Error {

}

public protocol Unpacker {
    @discardableResult
    func contentInfo(in filePath: String, completion: @escaping ContentInfoCompletion) -> UnpackTask
    @discardableResult
    func unpack(fileAt filePath: String, in destinationPath: String, completion: @escaping UnpackTaskCompletion) -> UnpackTask
}

public protocol UnpackTask {
    func cancel()
}

// MARK: File Info

public protocol FileInfo {
    var fileName: String { get }
    var fileCRC: Int { get }
}
