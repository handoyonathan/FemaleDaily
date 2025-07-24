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

    let landmarks = [
        Landmark(name: "Pond's Glow Tunnel", imageName: "MakeupLM", boothID: "Booth38", relativeX: 0.75, relativeY: 0.4),
        Landmark(name: "Booth 19", imageName: "MakeupLM", boothID: "Booth19", relativeX: 0.23, relativeY: 0.54)
    ]

    var body: some View {
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

            // ✅ 2. Search bar & search list
            VStack(spacing: 0) {
                SearchBar(searchText: $viewModel.searchText, isActive: $isSearchBarActive)
                    .onTapGesture {
                        isSearchBarActive = true
                        showSearchList = true
                    }
                    .onChange(of: viewModel.searchText) { newValue in
                        if newValue.isEmpty && !isSearchBarActive {
                            showSearchList = false
                        }
                    }

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
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .zIndex(2)

            // 3. White background behind list for clarity
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
                    // Transparent background to detect outside tap
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                selectedLandmark = nil
                            }
                        }

                    MapModalityView(
                        showModal: Binding(
                            get: { selectedLandmark != nil },
                            set: { if !$0 { selectedLandmark = nil } }
                        ),
                        landmark: selected,
                        brands: DummyBrands.data.filter { $0.landmarkBrand == selected.name }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
                .zIndex(1)
            }
        }
    }
}


#Preview {
    StaticMapView()
}

