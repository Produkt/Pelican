//
//  RarTests.swift
//  PelicanSampleProject
//
//  Created by Daniel Garcia on 10/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import XCTest
import Pelican

class RarTests: PelicanTests {
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: rarCachesPath())
        try? FileManager.default.removeItem(atPath: unrarCachesPath())
    }

    func testCanFetchFileInfo_Sync() {
        // Given
        let filePath = pathForFixture("Pelican.rar")!
        let rarUnpacker = Pelican.rarUnpacker()

        // When
        let contentInfoResult = rarUnpacker.contentInfo(in: filePath)
        guard case let .success(contentInfo) = contentInfoResult else {
            XCTAssert(false, "ContentInfo fetch should succeed")
            return
        }

        // Then
        XCTAssertEqual(contentInfo.count, 4)
        XCTAssertEqual(contentInfo[0].fileName, "CompressedFile1.txt")
        XCTAssertEqual(contentInfo[1].fileName, "CompressedFile2.txt")
        XCTAssertEqual(contentInfo[2].fileName, "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(contentInfo[3].fileName, "Pelecanus_conspicillatus_-Australia_-8_LICENCE")
    }

    func testCanFetchFileInfo_Async() {
        // Given
        let filePath = pathForFixture("Pelican.rar")!
        let rarUnpacker = Pelican.rarUnpacker()

        // When
        let contentInfoExpectation = expectation(description: "contentInfo")
        var contentInfo:[RarFileInfo]? = nil
        rarUnpacker.contentInfo(in: filePath) { result in
            guard case let .success(contentInfoResult) = result else { return }
            contentInfo = contentInfoResult
            contentInfoExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertEqual(contentInfo?.count, 4)
        XCTAssertEqual(contentInfo?[0].fileName, "CompressedFile1.txt")
        XCTAssertEqual(contentInfo?[1].fileName, "CompressedFile2.txt")
        XCTAssertEqual(contentInfo?[2].fileName, "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(contentInfo?[3].fileName, "Pelecanus_conspicillatus_-Australia_-8_LICENCE")
    }

    func testCanUnrarFile_Sync() {
        // Given
        let filePath = pathForFixture("Pelican.rar")!
        let rarUnpacker = Pelican.rarUnpacker()
        let unpackPath = unrarCachesPath()

        // When
        let unrarResult = rarUnpacker.unpack(fileAt: filePath, in: unpackPath)
        guard case let .success(unzipSummary) = unrarResult else {
            XCTAssert(false, "Unzip whole file should succeed")
            return
        }

        // Then
        let unzippedFilesInfo = unzipSummary.unpackedFiles
        XCTAssertEqual(unzippedFilesInfo.count, 4)
        XCTAssertEqual(unzippedFilesInfo[0].fileName, "CompressedFile1.txt")
        XCTAssertEqual(unzippedFilesInfo[1].fileName, "CompressedFile2.txt")
        XCTAssertEqual(unzippedFilesInfo[2].fileName, "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(unzippedFilesInfo[3].fileName, "Pelecanus_conspicillatus_-Australia_-8_LICENCE")

        XCTAssert(FileManager.default.fileExists(atPath: unpackPath))
        let contents = contentsOfFolder(at: unpackPath)!
        XCTAssertEqual(contents.count, 4)
        XCTAssertEqual(contents[0], "CompressedFile1.txt")
        XCTAssertEqual(contents[1], "CompressedFile2.txt")
        XCTAssertEqual(contents[2], "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(contents[3], "Pelecanus_conspicillatus_-Australia_-8_LICENCE")
    }

    func testCanUnrarFile_Async() {
        // Given
        let filePath = pathForFixture("Pelican.rar")!
        let rarUnpacker = Pelican.rarUnpacker()
        let unpackPath = unrarCachesPath()

        // When
        let unrarExpectation = expectation(description: "unrar")
        var unrarSummary: UnpackContentSummary! = nil
        rarUnpacker.unpack(fileAt: filePath, in: unpackPath, completion: { result in
            guard case let .success(summary) = result else { return }
            unrarSummary = summary
            unrarExpectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        let unraredFilesInfo = unrarSummary.unpackedFiles
        XCTAssertEqual(unraredFilesInfo.count, 4)
        XCTAssertEqual(unraredFilesInfo[0].fileName, "CompressedFile1.txt")
        XCTAssertEqual(unraredFilesInfo[1].fileName, "CompressedFile2.txt")
        XCTAssertEqual(unraredFilesInfo[2].fileName, "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(unraredFilesInfo[3].fileName, "Pelecanus_conspicillatus_-Australia_-8_LICENCE")

        XCTAssert(FileManager.default.fileExists(atPath: unpackPath))
        let contents = contentsOfFolder(at: unpackPath)!
        XCTAssertEqual(contents.count, 4)
        XCTAssertEqual(contents[0], "CompressedFile1.txt")
        XCTAssertEqual(contents[1], "CompressedFile2.txt")
        XCTAssertEqual(contents[2], "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(contents[3], "Pelecanus_conspicillatus_-Australia_-8_LICENCE")
    }

    private func rarCachesPath() -> String {
        return cachesPath(at: "rared")
    }

    private func unrarCachesPath() -> String {
        return cachesPath(at: "unrared")
    }
}
