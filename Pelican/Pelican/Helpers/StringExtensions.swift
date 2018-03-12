//
//  Extensions.swift
//  Pelican
//
//  Created by Daniel Garcia on 09/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Foundation

extension String {

    var pathExtension: String {
        return (self as NSString).pathExtension
    }

    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }

    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }

    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}
