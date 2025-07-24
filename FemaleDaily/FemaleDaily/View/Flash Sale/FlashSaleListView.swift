//
//  FlashSaleListView.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

struct FlashSaleListView: View {
    @ObservedObject var viewModel: FlashSaleViewModel
    @Binding var isShowingDetail: Bool
    @Binding var selectedBrandDetail: BrandDetail?
    @EnvironmentObject var queueService: QueueService
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.filteredEventsByHour.keys.sorted(), id: \.self) { hour in
                    Section {
                        ForEach(viewModel.filteredEventsByHour[hour] ?? []) { event in
                            Button(action: {
                                selectedBrandDetail = event.brandDetail
                                isShowingDetail = true
                            }) {
                                FlashSaleItemView(event: event, queueCount: queueService.queueList.filter { $0.status.lowercased() == "queueing" }.count)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } header: {
                        Text(hour)
                            .font(.headline)
                            .fontWeight(.regular)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
        }
    }
}

struct FlashSaleListView_Previews: PreviewProvider {
    @State static var isShowing = false
    @State static var selectedBrand: BrandDetail? = nil
    
    static var previews: some View {
        FlashSaleListView(
            viewModel: FlashSaleViewModel(),
            isShowingDetail: $isShowing,
            selectedBrandDetail: $selectedBrand
        )
        .environmentObject(QueueService.shared)
    }
}
