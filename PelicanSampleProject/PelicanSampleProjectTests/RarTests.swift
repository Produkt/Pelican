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

    private func rarCachesPath() -> String {
        return cachesPath(at: "rared")
    }

    private func unrarCachesPath() -> String {
        return cachesPath(at: "unrared")
    }
}
