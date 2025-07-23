//
//  DateSelectorView.swift
//  FlashSale
//
//  Created by Daven Karim on 18/07/25.
//

import SwiftUI

struct DateSelectorView: View {
    @ObservedObject var viewModel: DateSelectorViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.availableDates, id: \.self) { date in
                    dateView(for: date)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func dateView(for date: Date) -> some View {
        VStack(spacing: 4) {
            Text(viewModel.dayOfWeek(from: date))
                .font(.caption)
            //                .foregroundColor(.gray)
            Text(viewModel.dateNumber(from: date))
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(width: 45, height: 56)
        
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(viewModel.isDateSelected(date) ? Color.red : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(viewModel.isDateSelected(date) ? Color.red : Color.gray, lineWidth: 0.5)
        )
        .foregroundColor(viewModel.isDateSelected(date) ? .white : .gray)
        .onTapGesture {
            viewModel.selectedDate = date
        }
    }
}

struct DateSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        // 1. Create sample dates (3-6 July 2025)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let sampleDates = [
            dateFormatter.date(from: "2025/07/03")!,
            dateFormatter.date(from: "2025/07/04")!,
            dateFormatter.date(from: "2025/07/05")!,
            dateFormatter.date(from: "2025/07/06")!
        ]
        
        // 2. Create mock view model
        let mockViewModel = DateSelectorViewModel(
            selectedDate: sampleDates[0], // Default selected: July 3
            availableDates: sampleDates
        )
        
        // 3. Return the view with sample data
        return DateSelectorView(viewModel: mockViewModel)
            .padding(.vertical)
            .previewLayout(.sizeThatFits)
    }
}

// Mock DateSelectorViewModel for preview
class MockDateSelectorViewModel: DateSelectorViewModel {
    override func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    override func dateNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    override func isDateSelected(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}
