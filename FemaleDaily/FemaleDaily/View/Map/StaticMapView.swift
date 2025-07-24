//
//  MapView.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 23/07/25.
//

import SwiftUI

struct StaticMapView: View {
    @State private var selectedLandmark: Landmark? = nil
    @State private var focusLandmark: Landmark? = nil
    @State private var showModal = false
    @StateObject private var viewModel = BrandListViewModel()
    @State private var showSearchList = false
    @State private var isSearchBarActive = false
    @EnvironmentObject var queueService: QueueService

    let landmarks = [
        Landmark(name: "Pond's Glow Tunnel", imageName: "MakeupLM", boothID: "Booth38", relativeX: 0.75, relativeY: 0.4),
        Landmark(name: "Booth 19", imageName: "MakeupLM", boothID: "Booth19", relativeX: 0.23, relativeY: 0.54)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 1. Tap outside to dismiss
                if showSearchList {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                showSearchList = false
                                isSearchBarActive = false
                                viewModel.searchText = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                        .zIndex(1.5)
                }

                // 2. Search bar & search list
                VStack(spacing: 0) {
                    SearchBar(searchText: $viewModel.searchText, isActive: $isSearchBarActive)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity)

                    if showSearchList || !viewModel.searchText.isEmpty || isSearchBarActive {
                        SearchList(
                            viewModel: viewModel,
                            landmarks: landmarks,
                            focusLandmark: $focusLandmark,
                            onBrandSelected: {
                                withAnimation {
                                    showSearchList = false
                                    isSearchBarActive = false
                                }
                                viewModel.searchText = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        )
                        .background(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .clipped()
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .zIndex(2)

                // 3. White background behind list
                if showSearchList || !viewModel.searchText.isEmpty || isSearchBarActive {
                    Color.white
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(1)
                }

                // 4. Main map content
                IndoorMap(landmarks: landmarks, selectedLandmark: $selectedLandmark, focusLandmark: $focusLandmark)

                // 5. Modal for booth selection
                if let selected = selectedLandmark {
                    ZStack {
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    selectedLandmark = nil
                                }
                            }
                    }
                    .zIndex(1)
                }
            }
            .sheet(isPresented: Binding(
                get: { selectedLandmark != nil },
                set: { if !$0 { selectedLandmark = nil } }
            )) {
                if let selected = selectedLandmark {
                    MapModalityView(landmark: selected, brands: DummyBrands.data.filter { $0.landmarkBrand == selected.name })
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .ignoresSafeArea(.keyboard)
                        .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                queueService.debugFetchAllRecords()
                queueService.fetchQueue {
                    print("StaticMapView queue fetch completed")
                }
            }
        }
    }
}

#Preview {
    StaticMapView()
        .environmentObject(QueueService.shared)
}
