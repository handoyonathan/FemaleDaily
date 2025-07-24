//
//  SearchBarView.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @EnvironmentObject var queueService: QueueService

    var body: some View {
        HStack(spacing: 8) {
            // Search Box
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.red)
                
                TextField("Search your favorite brands here..", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.subheadline)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )

            // Navigation to MyQueueView
            NavigationLink(destination: MyQueueView()
                .environmentObject(queueService)
                .onAppear {
                    print("Navigated to MyQueueView from person icon")
                }) {
                Image(systemName: "person")
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.top, 5)
        .padding(.bottom, 15)
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
        .environmentObject(QueueService.shared)
}
