//
//  Date+Ext.swift
//  PttMonkeysTicketCrawler
//
//  Created by marcus fu on 2019/4/26.
//  Copyright © 2019 marcus fu. All rights reserved.
//

import Foundation

extension Date {
    func toTimeString(format: String = "hh:mm a") -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
    
    func toCalendarComponentsPart() -> (year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int, weekday: Int){
        let components = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute,.second, .weekday], from: self)
        
        return (components.year!, components.month!, components.day!, components.hour!, components.minute!, components.second!, components.weekday!)
    }
}
