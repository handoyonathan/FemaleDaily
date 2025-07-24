//
//  BrandList.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 21/07/25.
//

import SwiftUI

struct SearchList: View {
    @ObservedObject var viewModel: BrandListViewModel
    let landmarks: [Landmark]
    @Binding var focusLandmark: Landmark?
    var onBrandSelected: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(viewModel.filteredBrands) { brand in
                    Button {
                        if let target = landmarks.first(where: { $0.name == brand.landmarkBrand }) {
                            focusLandmark = target
                            onBrandSelected?()
                        }
                    } label: {
                        BrandCard(
                            namaBrand: brand.namaBrand,
                            kategoriBrand: brand.kategoriBrand,
                            landmarkBrand: brand.landmarkBrand
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

            }
            .padding()
        }
    }
}



