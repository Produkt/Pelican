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
import Result

class ZipTests: PelicanTests {

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
        let packExpectation = expectation(description: "pack")
        var packResult: Result<Void, PackError>! = nil
        zipPacker.pack(files: filesToZipPaths, in: archivePath) { result in
            packResult = result
            packExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(packResult.error)
        XCTAssertTrue(FileManager.default.fileExists(atPath: archivePath), "Archive created");
        XCTAssertEqual(FileHash.md5HashOfFile(atPath: archivePath), expectedHash, "Hash of file mismatch at \(archivePath)")
    }

    func testCanFetchFileInfo() {
        // Given
        let filePath = pathForFixture("Pelican.zip")!
        let zipPacker = Pelican.unpacker(for: .ZIP)!

        // When
        let contentInfoExpectation = expectation(description: "contentInfo")
        var contentInfo:[FileInfo]! = nil
        zipPacker.contentInfo(in: filePath) { result in
            guard case let .success(contentInfoResult) = result else { return }
            contentInfo = contentInfoResult
            contentInfoExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertEqual(contentInfo.count, 4)
        XCTAssertEqual(contentInfo[0].fileName, "CompressedFile1.txt")
        XCTAssertEqual(contentInfo[1].fileName, "CompressedFile2.txt")
        XCTAssertEqual(contentInfo[2].fileName, "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(contentInfo[3].fileName, "Pelecanus_conspicillatus_-Australia_-8_LICENCE")
    }
}
