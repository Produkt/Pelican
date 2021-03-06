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

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(atPath: zipCachesPath())
        try? FileManager.default.removeItem(atPath: unzipCachesPath())
    }

    func testCanCreateAZipFile() {
        // Given
        let filesToZipPaths = [
            pathForFixture("File1.txt")!,
            pathForFixture("File2.txt")!
        ]
        let zipPath = zipCachesPath().appendingPathComponent("achive.zip")
        let zipPacker = Pelican.zipPacker()

        // When
        let packExpectation = expectation(description: "pack")
        var packResult: Result<Void, PackError>! = nil
        zipPacker.pack(files: filesToZipPaths, in: zipPath) { result in
            packResult = result
            packExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNil(packResult.error)
        XCTAssertTrue(FileManager.default.fileExists(atPath: zipPath), "Archive created");
    }

    func testCanFetchFileInfo_Sync() {
        // Given
        let filePath = pathForFixture("Pelican.zip")!
        let zipUnpacker = Pelican.zipUnpacker()

        // When
        let contentInfoResult = zipUnpacker.contentInfo(in: filePath)
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
        let filePath = pathForFixture("Pelican.zip")!
        let zipUnpacker = Pelican.zipUnpacker()

        // When
        let contentInfoExpectation = expectation(description: "contentInfo")
        var contentInfo:[ZipFileInfo]? = nil
        zipUnpacker.contentInfo(in: filePath) { result in
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

    func testCanUnzipFile_Sync() {
        // Given
        let filePath = pathForFixture("Pelican.zip")!
        let zipUnpacker = Pelican.zipUnpacker()
        let unpackPath = unzipCachesPath()

        // When
        let unzipResult = zipUnpacker.unpack(fileAt: filePath, in: unpackPath)
        guard case let .success(unzipSummary) = unzipResult else {
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
        XCTAssert(contents.contains("CompressedFile1.txt"))
        XCTAssert(contents.contains("CompressedFile2.txt"))
        XCTAssert(contents.contains("Pelecanus_conspicillatus_-Australia_-8.jpg"))
        XCTAssert(contents.contains("Pelecanus_conspicillatus_-Australia_-8_LICENCE"))
    }

    func testCanUnzipFile_Async() {
        // Given
        let filePath = pathForFixture("Pelican.zip")!
        let zipUnpacker = Pelican.zipUnpacker()
        let unpackPath = unzipCachesPath()

        // When
        let unzipExpectation = expectation(description: "unzip")
        var unzipSummary: UnpackContentSummary! = nil
        zipUnpacker.unpack(fileAt: filePath, in: unpackPath, completion: { result in
            guard case let .success(summary) = result else { return }
            unzipSummary = summary
            unzipExpectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)

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
        XCTAssert(contents.contains("CompressedFile1.txt"))
        XCTAssert(contents.contains("CompressedFile2.txt"))
        XCTAssert(contents.contains("Pelecanus_conspicillatus_-Australia_-8.jpg"))
        XCTAssert(contents.contains("Pelecanus_conspicillatus_-Australia_-8_LICENCE"))
    }

    func testCanUnzipASpecificFileUsingAFileInfo_Sync() {
        // Given
        let filePath = pathForFixture("Pelican.zip")!
        let expectedFileData = NSData(contentsOfFile: pathForFixture("Pelecanus_conspicillatus_-Australia_-8.jpg")!)! as Data
        let zipUnpacker = Pelican.zipUnpacker()

        // When
        let contentInfoResult = zipUnpacker.contentInfo(in: filePath)
        guard case let .success(contentInfo) = contentInfoResult else {
            XCTAssert(false, "ContentInfo fetch should succeed")
            return
        }

        let unzipSingleFileResult = zipUnpacker.unpack(fileWith: contentInfo[2], from: filePath)
        guard case let .success(fileData) = unzipSingleFileResult else {
            XCTAssert(false, "Unzip single file should succeed")
            return
        }

        // Then
        XCTAssertNotNil(fileData)
        XCTAssertEqual(fileData, expectedFileData)
    }

    func testCanUnzipASpecificFileUsingAFileInfo_Async() {
        // Given
        let filePath = pathForFixture("Pelican.zip")!
        let expectedFileData = NSData(contentsOfFile: pathForFixture("Pelecanus_conspicillatus_-Australia_-8.jpg")!)! as Data
        let zipUnpacker = Pelican.zipUnpacker()

        // When
        let contentInfoExpectation = expectation(description: "contentInfo")
        var contentInfo:[ZipFileInfo]! = nil
        zipUnpacker.contentInfo(in: filePath) { result in
            guard case let .success(contentInfoResult) = result else { return }
            contentInfo = contentInfoResult
            contentInfoExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        let unzipExpectation = expectation(description: "unzip")
        var fileData: Data! = nil
        zipUnpacker.unpack(fileWith: contentInfo[2], from: filePath) { result in
            guard case let .success(data) = result else { return }
            fileData = data
            unzipExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(fileData)
        XCTAssertEqual(fileData, expectedFileData)
    }

    private func zipCachesPath() -> String {
        return cachesPath(at: "zipped")
    }

    private func unzipCachesPath() -> String {
        return cachesPath(at: "unzipped")
    }
}
