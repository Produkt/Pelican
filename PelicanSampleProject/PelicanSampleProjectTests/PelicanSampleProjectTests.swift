//
//  PelicanSampleProjectTests.swift
//  PelicanSampleProjectTests
//
//  Created by Daniel Garcia on 08/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import XCTest
@testable import PelicanSampleProject
import Pelican

class PelicanSampleProjectTests: XCTestCase {

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
        super.tearDown()
    }

    func testCanCreateAZipFile() {
        // Given
        let filesToZipPaths = [
            pathForFixture("File1.txt")!,
            pathForFixture("File2.txt")!
        ]
        let archivePath = cachesPath(at: "zipped").appendingPathComponent("achive.zip")
        let zipPacker = Pelican.packer(for: .ZIP)!

        // When
        zipPacker.pack(files: filesToZipPaths, in: archivePath)

        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: archivePath), "Archive created");
    }
}

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
