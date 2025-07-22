//
//  Untitled.swift
//  FlashSale
//
//  Created by Daven Karim on 18/07/25.
//

import Foundation

struct FlashSaleEvent: Identifiable {
    let id = UUID()
    let brandName: String
    let description: String
    let startTime: Date
    let endTime: Date
    let date: Date // tanggal acara
    let brandDetail: BrandDetail
    
    // Helper properties
    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        return formatter.string(from: startTime)
    }
}
