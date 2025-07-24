//
//  MapModalityView.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 22/07/25.
//

import SwiftUI

struct MapModalityView: View {
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height * 0.6
    @GestureState private var dragOffset = CGSize.zero
    @Binding var showModal: Bool
    let landmark: Landmark
    let brands: [Brand]

    var body: some View {
        let filteredBrands = brands.filter { $0.landmarkBrand == landmark.name }

        VStack(spacing: 0) {
            // Grab indicator
            Capsule()
                .frame(width: 56, height: 4)
                .foregroundColor(.gray)
                .padding(.top, 10)
                .padding(.bottom, 5)

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
            if filteredBrands.isEmpty {
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
        .frame(height: UIScreen.main.bounds.height * 0.85)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: -5)
        .offset(y: max(0, offsetY + dragOffset.height))
        .onChange(of: showModal) {
            if showModal {
                offsetY = UIScreen.main.bounds.height * 0.6
            }
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    let height = UIScreen.main.bounds.height
                    let newOffset = offsetY + value.translation.height

                    withAnimation {
                        if newOffset > height * 0.85 {
                            showModal = false
                            offsetY = height * 0.6
                        } else if newOffset < height * 0.25 {
                            offsetY = 80
                        } else if newOffset > height * 0.6 {
                            offsetY = height * 0.75
                        } else {
                            offsetY = height * 0.4
                        }
                    }
                }
        )
    }
}

#Preview {
    MapModalityView(
        showModal: .constant(true),
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
