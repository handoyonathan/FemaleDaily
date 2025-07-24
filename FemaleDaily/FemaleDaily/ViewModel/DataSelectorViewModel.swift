//
//  DateSelectorViewModel.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import Foundation

class DateSelectorViewModel: ObservableObject {
    @Published var selectedDate: Date
    let availableDates: [Date]
    
    init(selectedDate: Date = Date(), availableDates: [Date]) {
        self.selectedDate = selectedDate
        self.availableDates = availableDates
    }
    
    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    func dateNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}
