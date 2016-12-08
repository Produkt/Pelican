//
//  PelicanTests.swift
//  PelicanTests
//
//  Created by Daniel Garcia on 06/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import XCTest

class PelicanTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCanCreateAZipFile() {
        let filesToZipPaths = [
            pathForFixture("File1.txt")!,
            pathForFixture("File2.txt")!
        ]


    }
}

extension PelicanTests {
    func cachesPath(at directory: String) -> String {
        let path = NSTemporaryDirectory().appendingPathComponent(Bundle.main.bundleIdentifier!).appendingPathComponent(directory)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }

    func pathForFixture(_ named: String) -> String? {
        return Bundle.main.path(forResource: named.deletingPathExtension, ofType: named.pathExtension)
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
