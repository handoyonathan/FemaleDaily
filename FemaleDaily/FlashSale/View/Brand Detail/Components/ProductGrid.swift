//
//  ProductGrid.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

struct ProductGrid: View {
    let products: [Product]
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(products) { product in
                VStack(alignment: .leading, spacing: 8) {
                    Image(product.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 138)
                        .frame(maxWidth: .infinity)
//                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.headline)
                        Text(product.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ProductGrid(products: [
        Product(name: "Produk A", description: "Deskripsi produk A", image: "product1"),
        Product(name: "Produk B", description: "Deskripsi produk B", image: "product2"),
        Product(name: "Produk C", description: "Deskripsi produk C", image: "product3"),
        Product(name: "Produk D", description: "Deskripsi produk D", image: "product4")
    ])
}
