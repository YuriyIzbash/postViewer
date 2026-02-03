//
//  RelativeDateText.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

func relativeDateString(from date: Date, relativeTo now: Date = Date(), calendar: Calendar = .current) -> String {
    let startOfDate = calendar.startOfDay(for: date)
    let startOfNow = calendar.startOfDay(for: now)

    if startOfDate == startOfNow {
        return "Today"
    }

    let components = calendar.dateComponents([.year, .month, .day], from: startOfDate, to: startOfNow)

    if let years = components.year, years >= 1 {
        if years == 1 { return "1 year ago" }
        return "\(years) years ago"
    }

    if let months = components.month, months >= 1 {
        if months == 1 { return "1 month ago" }
        return "\(months) months ago"
    }

    let days = components.day ?? 0
    if days <= 0 { return "Today" }
    if days == 1 { return "1 day ago" }
    return "\(days) days ago"
}
