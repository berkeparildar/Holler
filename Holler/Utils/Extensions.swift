//
//  Extensions.swift
//  Holler
//
//  Created by Berke Parıldar on 1.06.2024.
//

import Foundation

extension TimeInterval {
    var formattedTimeString: String {
        let interval = Int(self)
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = interval / 60
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = interval / 3600
            return "\(hours)h"
        } else if interval < 604800 {
            let days = interval / 86400
            return "\(days)d"
        } else {
            let weeks = interval / 604800
            return "\(weeks)w"
        }
    }
}
