//
//  Pelican.swift
//  Pelican
//
//  Created by Daniel Garcia on 06/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

public enum PelicanType {
    case ZIP
    case RAR
}

public class Pelican {
    open static func packer(for type: PelicanType) -> Packer? {
        switch type {
        case .ZIP:
            return ZipPacker()
        case .RAR:
            // As RAR is a proprietary type, we cant pack. Only unpack
            return nil
        }
    }
}

public protocol Unpacker {

}

public protocol Packer {
    @discardableResult
    func pack(files filePaths: [String], in filePath: String) -> PackOperation
}

public protocol PackOperation {

}
