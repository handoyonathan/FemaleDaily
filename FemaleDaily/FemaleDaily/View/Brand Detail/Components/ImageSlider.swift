//
//  ImageSlider.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

struct ImageSlider: View {
    let images: [String]
    @Binding var currentIndex: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // Button panah kanan
            Button(action: {
                currentIndex = (currentIndex + 1) % images.count
            }) {
                Image(systemName: "arrow.turn.up.right")
                    .padding()
                    .foregroundStyle(.red)
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }
            .padding()
        }
    }
}

