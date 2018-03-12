//
//  RarTests.swift
//  PelicanSampleProject
//
//  Created by Daniel Garcia on 10/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import XCTest
@testable import Pelican

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
            guard case let .success(contentInfoResult) = result else {
                XCTAssert(false, "ContentInfo fetch should succeed")
                return
            }
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
        guard case let .success(unrarSummary) = unrarResult else {
            XCTAssert(false, "Unrar whole file should succeed")
            return
        }

        // Then
        let unrarpedFilesInfo = unrarSummary.unpackedFiles
        XCTAssertEqual(unrarpedFilesInfo.count, 4)
        XCTAssertEqual(unrarpedFilesInfo[0].fileName, "CompressedFile1.txt")
        XCTAssertEqual(unrarpedFilesInfo[1].fileName, "CompressedFile2.txt")
        XCTAssertEqual(unrarpedFilesInfo[2].fileName, "Pelecanus_conspicillatus_-Australia_-8.jpg")
        XCTAssertEqual(unrarpedFilesInfo[3].fileName, "Pelecanus_conspicillatus_-Australia_-8_LICENCE")

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
            guard case let .success(summary) = result else {
                XCTAssert(false, "Unrar whole file should succeed")
                return
            }
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

    func testCanUnrarASpecificFileUsingAFileInfo_Sync() {
        // Given
        let filePath = pathForFixture("Pelican.rar")!
        let expectedFileData = NSData(contentsOfFile: pathForFixture("Pelecanus_conspicillatus_-Australia_-8.jpg")!)! as Data
        let rarUnpacker = Pelican.rarUnpacker()

        // When
        let contentInfoResult = rarUnpacker.contentInfo(in: filePath)
        guard case let .success(contentInfo) = contentInfoResult else {
            XCTAssert(false, "ContentInfo fetch should succeed")
            return
        }

        let unrarSingleFileResult = rarUnpacker.unpack(fileWith: contentInfo[2], from: filePath)
        guard case let .success(fileData) = unrarSingleFileResult else {
            XCTAssert(false, "Unrar single file should succeed")
            return
        }

        // Then
        XCTAssertNotNil(fileData)
        XCTAssertEqual(fileData, expectedFileData)
    }

    func testCanUnrarASpecificFileUsingAFileInfo_Async() {
        // Given
        let filePath = pathForFixture("Pelican.rar")!
        let expectedFileData = NSData(contentsOfFile: pathForFixture("Pelecanus_conspicillatus_-Australia_-8.jpg")!)! as Data
        let rarUnpacker = Pelican.rarUnpacker()

        // When
        let contentInfoExpectation = expectation(description: "contentInfo")
        var contentInfo:[RarFileInfo]! = nil
        rarUnpacker.contentInfo(in: filePath) { result in
            guard case let .success(contentInfoResult) = result else {
                XCTAssert(false, "ContentInfo fetch should succeed")
                return
            }
            contentInfo = contentInfoResult
            contentInfoExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        let unrarExpectation = expectation(description: "unrar")
        var fileData: Data! = nil
        rarUnpacker.unpack(fileWith: contentInfo[2], from: filePath) { result in
            guard case let .success(data) = result else {
                XCTAssert(false, "Unrar single file should succeed")
                return
            }
            fileData = data
            unrarExpectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        // Then
        XCTAssertNotNil(fileData)
        XCTAssertEqual(fileData, expectedFileData)
    }
    
    func testCanExtractAllPagesOfACBRComic() {
        // Given
        let comicFileName = "Comic.cbr"
        guard let filePath = pathForFixture(comicFileName) else {
            NSLog("\(#function) not run because \(comicFileName) was not found")
            return
        }
        let rarUnpacker = Pelican.rarUnpacker()
        let unpackPath = unrarCachesPath()
        
        // When
        let contentInfo = rarUnpacker.contentInfo(in: filePath).value!
        let unrarResult = rarUnpacker.unpack(fileAt: filePath, in: unpackPath)
        guard case let .success(unrarSummary) = unrarResult else {
            XCTAssert(false, "Unrar whole file should succeed")
            return
        }
        
        // Then
        let unrarpedFilesInfo = unrarSummary.unpackedFiles
        XCTAssertEqual(unrarpedFilesInfo.count, contentInfo.count)
        
        let fileManager = FileManager.default
        XCTAssert(fileManager.fileExists(atPath: unpackPath))
        let contents = contentsOfFolder(at: unpackPath)!
        XCTAssertEqual(contents.count, contentInfo.count)
        for fileInfo in contentInfo {
            XCTAssert(contents.contains(fileInfo.fileName), "\(fileInfo.fileName) was not extracted")
            guard let fileData = Data.contentsOfFile(path: unpackPath.appendingPathComponent(fileInfo.fileName)) else {
                XCTFail("\(fileInfo.fileName) could not be extracted")
                return
            }
            XCTAssertGreaterThan(fileData.count, 0)
            XCTAssertNotNil(UIImage(data: fileData), "Can't create an image from \(fileInfo.fileName)")
        }
    }
    
    func testCanExtractAllPagesFileByFileOfACBRComic() {
        // Given
        let comicFileName = "Comic.cbr"
        guard let filePath = pathForFixture(comicFileName) else {
            NSLog("\(#function) not run because \(comicFileName) was not found")
            return
        }
        let rarUnpacker = Pelican.rarUnpacker()
        
        // When
        let contentInfo = rarUnpacker.contentInfo(in: filePath).value!
        for fileInfo in contentInfo {
            let unpackFileResult = rarUnpacker.unpack(fileWith: fileInfo, from: filePath)
            
            // Then
            guard let fileData = unpackFileResult.value else {
                XCTFail("\(fileInfo.fileName) could not be extracted")
                return
            }
            XCTAssertGreaterThan(fileData.count, 0)
            XCTAssertNotNil(UIImage(data: fileData), "Can't create an image from \(fileInfo.fileName)")
        }
    }

    private func rarCachesPath() -> String {
        return cachesPath(at: "rared")
    }

    private func unrarCachesPath() -> String {
        return cachesPath(at: "unrared")
    }
}
