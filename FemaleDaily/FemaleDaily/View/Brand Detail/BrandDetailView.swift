//
//  BrandDetailView.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI
import CloudKit

struct BrandDetailView: View {
    let brand: BrandDetail
    @StateObject private var viewModel: BrandDetailViewModel
    @State private var isShowingQueue = false
    @EnvironmentObject var queueService: QueueService
    @Environment(\.presentationMode) var presentationMode

    init(brand: BrandDetail) {
        self.brand = brand
        _viewModel = StateObject(wrappedValue: BrandDetailViewModel(brand: brand))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    VStack(alignment: .leading, spacing: 20) {
                        // Image Slider
                        ImageSlider(images: viewModel.brand.images, currentIndex: $viewModel.currentImageIndex)
                            .frame(height: 250)

                        // Flash Sale Schedule
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FLASH SALE SCHEDULE")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(brand.flashSaleSchedule)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }

                // Product Catalog
                HStack {
                    Spacer()
                    Text("KATALOG FLASH SALE")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)

                ProductGrid(products: viewModel.brand.products)
                    .padding(.horizontal)

                // Footer with Queue Count and Button
                if !LoginViewModel.shared.isAdmin {
                    HStack(spacing: 16) {
                        // Queue Count
                        Text("Jumlah Antrian: \(queueService.queueList.filter { $0.status.lowercased() == "queueing" }.count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.red, lineWidth: 1)
                            )

                        // Ambil Antrian Button
                        Button(action: {
                            isShowingQueue = true
                        }) {
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
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .background(Color.white)
                }
            }
            .padding(.bottom)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(brand.name)
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
        .navigationDestination(isPresented: $isShowingQueue) {
            BrandQueueView()
                .environmentObject(queueService)
                .onAppear {
                    print("Navigated to BrandQueueView")
                }
        }
        .onAppear {
            queueService.fetchQueue {
                print("BrandDetailView queue fetch completed")
            }
        }
    }
}

struct BrandDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBrand = BrandDetail(
            name: "Skintific",
            description: "Premium beauty products",
            images: ["brand1", "brand2", "brand3"],
            flashSaleSchedule: "12:00 - 14:00",
            products: [
                Product(name: "Moisturizer", description: "Hydrating cream", image: "moisturizer"),
                Product(name: "Serum", description: "Anti-aging serum", image: "serum")
            ]
        )
        BrandDetailView(brand: sampleBrand)
            .environmentObject(QueueService.shared)
    }
}
