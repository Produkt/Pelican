//
//  TestExtensions.swift
//  PelicanSampleProject
//
//  Created by Daniel Garcia on 08/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Foundation

extension PelicanSampleProjectTests {

    func cachesPath(at directory: String) -> String {
        let path = NSTemporaryDirectory().appendingPathComponent(Bundle.main.bundleIdentifier!).appendingPathComponent(directory)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }

    func pathForFixture(_ named: String) -> String? {
        return Bundle(for: type(of: self)).path(forResource: named.deletingPathExtension, ofType: named.pathExtension)
    }
}

extension String {

    var pathExtension: String {
        return (self as NSString).pathExtension
    }

    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }

    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}


extension Data {

    func md5() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        withUnsafeBytes { (bytes: UnsafePointer<CChar>) -> Void in
            CC_MD5(bytes, CC_LONG(count), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }

        return digestHex
    }
}
