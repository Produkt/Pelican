//
//  RarFileInfo.swift
//  Pelican
//
//  Created by Daniel Garcia on 15/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import UnrarKit

extension RarFileInfo {

    init(from urkFileInfo: URKFileInfo, fileIndex: UInt) {
        fileName = urkFileInfo.filename
        archiveName = urkFileInfo.archiveName
        timestamp = urkFileInfo.timestamp
        fileCRC = UInt(urkFileInfo.crc)
        uncompressedSize = urkFileInfo.uncompressedSize
        compressedSize = urkFileInfo.compressedSize
        isEncryptedWithPassword = urkFileInfo.isEncryptedWithPassword
        isDirectory = urkFileInfo.isDirectory
        compressionMethod = RarCompressionMethod(fromUnrarKit: urkFileInfo.compressionMethod)
        hostOS = RarHostOS(fromUnrarKit: urkFileInfo.hostOS)
        index = fileIndex
    }
}

extension RarFileInfo.RarCompressionMethod {

    init(fromUnrarKit: URKCompressionMethod) {
        switch fromUnrarKit {
        case .storage:
            self = .storage
        case .fastest:
            self = .fastest
        case .fast:
            self = .fast
        case .normal:
            self = .normal
        case .good:
            self = .good
        case .best:
            self = .best
        }
    }

    func toUnrarKit() -> URKCompressionMethod {
        switch self {
        case .storage:
            return .storage
        case .fastest:
            return .fastest
        case .fast:
            return .fast
        case .normal:
            return .normal
        case .good:
            return .good
        case .best:
            return .best
        }
    }
}

extension RarFileInfo.RarHostOS {

    init(fromUnrarKit: URKHostOS) {
        switch fromUnrarKit {
        case .OSMSDOS:
            self = .MSDOS
        case .OSOS2:
            self = .OS2
        case .osWindows:
            self = .windows
        case .osUnix:
            self = .unix
        case .osMacOS:
            self = .macOS
        case .osBeOS:
            self = .beOS
        }
    }

    func toUnrarKit() -> URKHostOS {
        switch self {
        case .MSDOS:
            return .OSMSDOS
        case .OS2:
            return .OSOS2
        case .windows:
            return .osWindows
        case .unix:
            return .osUnix
        case .macOS:
            return .osMacOS
        case .beOS:
            return .osBeOS
        }
    }
}
