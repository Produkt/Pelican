//
//  ZipPacker.swift
//  Pelican
//
//  Created by Daniel Garcia on 08/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

import Foundation

public class ZipPacker: Packer {

    public let operationQueue: OperationQueue

    init(operationQueue: OperationQueue) {
        self.operationQueue = operationQueue
    }

    @discardableResult
    public func pack(files filePaths: [String], in filePath: String, completion: @escaping PackTaskCompletion) -> PackTask {
        let packOperation = ZipPackOperation(destinationPath: filePath, contentFilePaths: filePaths, completion: completion)
        operationQueue.addOperation(packOperation)
        return packOperation
    }
}

class ZipPackOperation: Operation, PackTask {

    private let destinationPath: String
    private let contentFilePaths: [String]
    private var zip: zipFile?
    private let chunkSize: Int = 16384
    private let completion: PackTaskCompletion

    init(destinationPath: String, contentFilePaths: [String], completion: @escaping PackTaskCompletion) {
        self.destinationPath = destinationPath
        self.contentFilePaths = contentFilePaths
        self.completion = completion
    }

    override func main() {
        super.main()
        zip = zipOpen((destinationPath as NSString).utf8String, APPEND_STATUS_CREATE);
        for filePath in contentFilePaths {
            addFile(from: filePath)
        }
        zipClose(zip, nil)
        completion(Result.success(()))
    }

    func addFile(from path: String) {
        let input = fopen((path as NSString).utf8String, "r")
        guard input != nil else { return }

        let fileName = ((path as NSString).lastPathComponent as NSString).utf8String
        var zipInfo: zip_fileinfo = zip_fileinfo(tmz_date: tm_zip(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0),
                                                 dosDate: 0,
                                                 internal_fa: 0,
                                                 external_fa: 0)
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            if let fileDate = fileAttributes.fileModificationDate() {
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fileDate)
                zipInfo.tmz_date.tm_sec = UInt32(components.second!)
                zipInfo.tmz_date.tm_min = UInt32(components.minute!)
                zipInfo.tmz_date.tm_hour = UInt32(components.hour!)
                zipInfo.tmz_date.tm_mday = UInt32(components.day!)
                zipInfo.tmz_date.tm_mon = UInt32(components.month!) - 1
                zipInfo.tmz_date.tm_year = UInt32(components.year!)
            }
        }
        catch {}
        zipOpenNewFileInZip3(zip, fileName, &zipInfo, nil, 0, nil, 0, nil, Z_DEFLATED, Z_DEFAULT_COMPRESSION, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, nil, 0)

        let buffer = malloc(chunkSize)
        var length: Int = 0
        while (feof(input) == 0) {
            length = fread(buffer, 1, chunkSize, input)
            zipWriteInFileInZip(zip, buffer, UInt32(length))
        }

        zipCloseFileInZip(zip)
        free(buffer)
        fclose(input)
    }
}
