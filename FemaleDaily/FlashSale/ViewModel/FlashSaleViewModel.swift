//
//  FlashSaleViewModel.swift
//  FlashSale
//
//  Created by Daven Karim on 18/07/25.
//

import Foundation

class FlashSaleViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var searchText: String = ""
    @Published var events: [FlashSaleEvent]
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        self.selectedDate = dateFormatter.date(from: "2025/07/03")!
        self.events = FlashSaleData.events
    }
    
    var filteredEventsByHour: [String: [FlashSaleEvent]] {
        let filtered = events.filter { event in
            Calendar.current.isDate(event.date, inSameDayAs: selectedDate) &&
            (searchText.isEmpty || event.brandName.lowercased().contains(searchText.lowercased()))
        }
        
        return Dictionary(grouping: filtered) { event in
            event.hourString
        }
    }
    
    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

extension FlashSaleViewModel {
    func getAvailableDates() -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return (0..<4).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: dateFormatter.date(from: "2025/07/03")!)
        }
    }
}
