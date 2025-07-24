//
//  MapModalityView.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 22/07/25.
//

import SwiftUI

struct MapModalityView: View {
    let landmark: Landmark
    let brands: [Brand]

    var body: some View {
        VStack(spacing: 0) {
            // Grab indicator
//            Capsule()
//                .frame(width: 56, height: 4)
//                .foregroundColor(.gray)
//                .padding(.top, 10)
//                .padding(.bottom, 5)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(landmark.name)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .fontWeight(.semibold)

                    Text("Discover what's at \(landmark.name)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
                .padding(.leading, 15)
                Spacer()
            }

            // Brand list
            if brands.isEmpty {
                Text("No brands found for this booth.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                SegmentedTabView(brands: brands, landmark: landmark)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
//        .background(Color.white.opacity(0.95))
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: -5)
    }
}

#Preview {
    MapModalityView(
        landmark: Landmark(
            name: "Booth 38",
            imageName: "MakeupLM",
            boothID: "Booth38",
            relativeX: 0.75,
            relativeY: 0.4
        ),
        brands: DummyBrands.data
    )
}
