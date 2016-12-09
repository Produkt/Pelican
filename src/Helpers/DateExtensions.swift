//
//  DateExtensions.swift
//  Pelican
//
//  Created by Daniel Garcia on 09/12/2016.
//  Copyright © 2016 Produkt Studio. All rights reserved.
//

extension Date {

    // Format from http://newsgroups.derkeiler.com/Archive/Comp/comp.os.msdos.programmer/2009-04/msg00060.html
    // Two consecutive words, or a longword, YYYYYYYMMMMDDDDD hhhhhmmmmmmsssss
    // YYYYYYY is years from 1980 = 0
    // sssss is (seconds/2).
    //
    // 3658 = 0011 0110 0101 1000 = 0011011 0010 11000 = 27 2 24 = 2007-02-24
    // 7423 = 0111 0100 0010 0011 - 01110 100001 00011 = 14 33 2 = 14:33:06

    static let kYearMask: UInt32 = 0xFE000000;
    static let kMonthMask: UInt32 = 0x1E00000;
    static let kDayMask: UInt32 = 0x1F0000;
    static let kHourMask: UInt32 = 0xF800;
    static let kMinuteMask: UInt32 = 0x7E0;
    static let kSecondMask: UInt32 = 0x1F;

    static let gregorianCalendar: NSCalendar = {
        return NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
    }()

    static func date(MSDOSFormat: UInt32) -> Date {
        var components = DateComponents()
        components.year = Int(UInt32(1980) + ((MSDOSFormat & kYearMask) >> 25))
        components.month = Int((MSDOSFormat & kMonthMask) >> 21)
        components.day = Int((MSDOSFormat & kDayMask) >> 16)
        components.hour = Int((MSDOSFormat & kHourMask) >> 11)
        components.minute = Int((MSDOSFormat & kMinuteMask) >> 5)
        components.second = Int((MSDOSFormat & kSecondMask) * 2)
        let dateFromComponents = gregorianCalendar.date(from: components)!
        return Date(timeInterval: 0, since: dateFromComponents)
    }
}
