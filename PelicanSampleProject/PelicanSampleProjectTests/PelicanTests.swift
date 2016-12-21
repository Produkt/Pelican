//
//  PelicanTests.swift
//  PelicanSampleProject
//
//  Created by Daniel Garcia on 08/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import XCTest

class PelicanTests: XCTestCase {
    
    let fixturesFolderName = "Fixtures"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func cachesPath(at directory: String) -> String {
        let path = NSTemporaryDirectory().appendingPathComponent(Bundle.main.bundleIdentifier!).appendingPathComponent(directory)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }

    func pathForFixture(_ named: String) -> String? {
        return Bundle(for: type(of: self)).path(forResource: named.deletingPathExtension, ofType: named.pathExtension, inDirectory: fixturesFolderName)
    }

    func contentsOfFolder(at path: String) -> [String]? {
        do{
            return try FileManager.default.contentsOfDirectory(atPath: path)
        }catch {
            return nil
        }
    }
}
