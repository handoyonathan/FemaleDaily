//
//  FlashSaleView.swift
//  FlashSale
//
//  Created by Daven Karim on 18/07/25.
//

import SwiftUI

struct FlashSaleView: View {
    @StateObject private var viewModel: FlashSaleViewModel
    @StateObject private var dateSelectorVM: DateSelectorViewModel
    @State private var isShowingDetail = false
    @State private var selectedBrandDetail: BrandDetail?
    @EnvironmentObject var queueService: QueueService

    init() {
        let dates = FlashSaleViewModel().getAvailableDates()
        _dateSelectorVM = StateObject(wrappedValue: DateSelectorViewModel(
            selectedDate: dates[0],
            availableDates: dates
        ))
        _viewModel = StateObject(wrappedValue: FlashSaleViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(searchText: $viewModel.searchText)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.monthYearString(for: viewModel.selectedDate))
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                DateSelectorView(viewModel: dateSelectorVM)
                    .onChange(of: dateSelectorVM.selectedDate) {
                        viewModel.selectedDate = dateSelectorVM.selectedDate
                    }
            }
            .padding(.bottom, 15)
            
            if viewModel.filteredEventsByHour.isEmpty {
                EmptyFlashSaleView()
            } else {
                FlashSaleListView(
                    viewModel: viewModel,
                    isShowingDetail: $isShowingDetail,
                    selectedBrandDetail: $selectedBrandDetail
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isShowingDetail) {
            if let brandDetail = selectedBrandDetail {
                BrandDetailView(brand: brandDetail)
                    .environmentObject(queueService)
            }
        }
        .onAppear {
            print("FlashSaleView appeared")
            queueService.fetchQueue {
                print("FlashSaleView initial queue fetch completed")
            }
        }
    }
}

#Preview {
    FlashSaleView()
        .environmentObject(QueueService.shared)
}
