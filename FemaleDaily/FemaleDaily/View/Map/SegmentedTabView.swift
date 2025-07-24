//
//  SegmentedTabView.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 21/07/25.
//

import SwiftUI

struct SegmentedTabView: View {
    @State private var selectedTab = 0  // 0 = Brands, 1 = Events

    let brands: [Brand]
    let landmark: Landmark

    var body: some View {
        VStack {
            Picker(selection: $selectedTab, label: Text("")) {
                Text("Brands").tag(0)
                Text("Flash Sale").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 10)
            .font(.system(size: 16))

            if selectedTab == 0 {
                let filteredBrands = brands.filter { $0.landmarkBrand == landmark.name }

                if filteredBrands.isEmpty {
                    Text("No brands available at this booth.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredBrands) { brand in
                                BrandCard(
                                    namaBrand: brand.namaBrand,
                                    kategoriBrand: brand.kategoriBrand,
                                    landmarkBrand: brand.landmarkBrand
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            } else {
                // Replace with actual event list if needed
                Text("Flash Sale coming soon...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}
