//
//  BrandDetailView.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

struct BrandDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: BrandDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header dengan back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    Spacer()
                    Text(viewModel.brand.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                
                //Header
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
//                        .opacity(0.1)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    VStack(alignment: .leading, spacing: 20){
                        // Image Slider
                        ImageSlider(images: viewModel.brand.images, currentIndex: $viewModel.currentImageIndex)
                            .frame(height: 250)
                        
                        // Flash Sale Schedule
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FLASH SALE SCHEDULE")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Description. Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                // Katalog Produk
                HStack() {
                    Spacer()
                    
                    Text("KATALOG FLASH SALE")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                
                ProductGrid(products: viewModel.brand.products)
                    .padding(.horizontal)
            }
            
            // Footer dengan tombol
            HStack(spacing: 16) {
                // Tombol Jumlah Antrian
                Text("Jumlah Antrian: 50")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.red, lineWidth: 1)
                    )
                
                // Tombol Ambil Antrian
                Text("Ambil Antrian >")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.red, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .background(Color.white)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

// Preview
struct BrandDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBrand = BrandDetail(
            name: "Brand X",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            images: ["placeholder1", "placeholder2"],
            flashSaleSchedule: "12:00 - 14:00",
            products: [
                Product(name: "Produk A", description: "Deskripsi produk A", image: "product1"),
                Product(name: "Produk B", description: "Deskripsi produk B", image: "product2"),
                Product(name: "Produk C", description: "Deskripsi produk C", image: "product3"),
                Product(name: "Produk D", description: "Deskripsi produk D", image: "product4")
            ]
        )
        
        BrandDetailView(viewModel: BrandDetailViewModel(brand: sampleBrand))
    }
}
