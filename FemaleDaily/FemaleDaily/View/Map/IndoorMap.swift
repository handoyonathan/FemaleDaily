//
//  IndoorMap.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 23/07/25.
//

import SwiftUI

struct IndoorMap: View {
    let landmarks: [Landmark]
    @Binding var selectedLandmark: Landmark?
//    Buat nentuin fokus landmark
    @Binding var focusLandmark: Landmark?

    @State private var scale: CGFloat = 2.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    Image("HdMap")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width)
                    

                    // Landmarks layered over image
                    ForEach(landmarks) { landmark in
                        Button(action: {
                            let isSame = selectedLandmark?.id == landmark.id
                            selectedLandmark = isSame ? nil : landmark
                            if !isSame {
                                focusLandmark = landmark // This triggers zoom+pan
                            }
                        }) {
                            Image(landmark.imageName)
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .position(x: geo.size.width * landmark.relativeX,
                                  y: geo.size.height * landmark.relativeY)
                    }
                }
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                scale = min(max(scale, 1.0), 3.0)
                                lastScale = scale
                                offset = clampOffset(offset, in: geo.size)
                                lastOffset = offset
                            },
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                offset = clampOffset(offset, in: geo.size)
                                lastOffset = offset
                            }
                    )
                )
                .onChange(of: focusLandmark) { newValue in
                    guard let landmark = newValue else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let containerWidth = geo.size.width
                        let containerHeight = geo.size.height
                        
                        let targetX = containerWidth * landmark.relativeX - 150
                        let targetY = containerHeight * landmark.relativeY - 200
                        
                        let newScale: CGFloat = 2.5
                        
                        let centeredOffset = CGSize(
                            width: geo.size.width / 2 - targetX * newScale,
                            height: geo.size.height / 2 - targetY * newScale
                        )
                        
                        withAnimation {
                            scale = newScale
                            lastScale = newScale
                            offset = clampOffset(centeredOffset, in: geo.size)
                            lastOffset = offset
                        }
                    }
                }

            }
        }
    }

    // Clamp offset to prevent the map from moving too far off-screen
    private func clampOffset(_ offset: CGSize, in containerSize: CGSize) -> CGSize {
        let maxOffsetX = max((containerSize.width * scale - containerSize.width) / 2, 0)
        let maxOffsetY = max((containerSize.height * scale - containerSize.height) / 2, 0)

        let clampedX = min(max(offset.width, -maxOffsetX), maxOffsetX)
        let clampedY = min(max(offset.height, -maxOffsetY), maxOffsetY)

        return CGSize(width: clampedX, height: clampedY)
    }
}
