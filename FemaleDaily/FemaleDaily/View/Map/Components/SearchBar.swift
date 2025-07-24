//
//  SearchBar.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 22/07/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isActive: Bool
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject var queueService: QueueService
    
    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.red)
                    .font(.system(size: 24))
                    .padding(.leading, 10)
                
                TextField("Search", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { focused in
                        isActive = focused
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(Color(.white))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke((isActive || !searchText.isEmpty) ? Color.red : Color.gray, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = true
            }
            
            NavigationLink(destination: FlashSaleView()
                .environmentObject(queueService)
                .onAppear {
                    print("Navigated to FlashSaleView from tag icon")
                }) {
                    Image(systemName: "tag")
                        .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke((isActive || !searchText.isEmpty) ? Color.red : Color.gray, lineWidth: 1)
                        )
                }
            
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
                                .stroke((isActive || !searchText.isEmpty) ? Color.red : Color.gray, lineWidth: 1)
                        )
                }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }
}
