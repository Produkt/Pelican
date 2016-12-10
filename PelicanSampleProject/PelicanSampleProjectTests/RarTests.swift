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

    private func rarCachesPath() -> String {
        return cachesPath(at: "rared")
    }

    private func unrarCachesPath() -> String {
        return cachesPath(at: "unrared")
    }
}
