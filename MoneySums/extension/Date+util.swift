//
//  Date+util.swift
//  MoneySums
//
//  Created by Nkokhelo Mhlongo on 2021/09/26.
//

import Foundation

extension Date {
  func niceDescription() -> String {
    let secondsAgo = Int(Date().timeIntervalSince(self))
    let minute = 60
    let hour = 60 * minute
    let day = 24 * hour
    let week = 7 * day
    
    if secondsAgo < 0 {
      return "Future"
    }
    else if secondsAgo < minute {
      return "\(secondsAgo)s"
    }
    else if secondsAgo < hour {
      return "\(secondsAgo / minute)m"
    }
    else if secondsAgo < day {
      return "\(secondsAgo / hour)h"
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = NSLocale.current
    if secondsAgo <= week {
      dateFormatter.dateFormat = "E '@' HH:mm"
    } else if self.get(.year) == Date().get(.year) {
      dateFormatter.dateFormat = "MMM d '@' HH:mm"
    } else {
      dateFormatter.dateFormat = "yyyy MMM d '@' HH:mm"
    }
    return dateFormatter.string(from: self)
  }
  
  func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
    return calendar.dateComponents(Set(components), from: self)
  }
  
  func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
    return calendar.component(component, from: self)
  }
}
