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
import FileMD5Hash

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
        let expectedHash = "4b0c329e4997abdb6d76e40f2625d465"
        let archivePath = cachesPath(at: "zipped").appendingPathComponent("achive.zip")
        let zipPacker = Pelican.packer(for: .ZIP)!

        // When
        zipPacker.pack(files: filesToZipPaths, in: archivePath)

        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: archivePath), "Archive created");
        XCTAssertEqual(FileHash.md5HashOfFile(atPath: archivePath), expectedHash, "Hash of file mismatch at \(archivePath)")
    }
}
