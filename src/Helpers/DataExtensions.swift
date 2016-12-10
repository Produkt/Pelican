//
//  DataExtensions.swift
//  Pelican
//
//  Created by Daniel Garcia on 10/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

extension Data {

    static func data(contentsOfFile path: String) -> Data? {
        return NSData(contentsOfFile: path) as Data?
    }
}
