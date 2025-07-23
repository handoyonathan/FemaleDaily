//
//  FlashSaleItemView.swift
//  FlashSale
//
//  Created by Daven Karim on 19/07/25.
//

import SwiftUI

struct FlashSaleItemView: View {
    let event: FlashSaleEvent
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(.systemGray4))
                .padding(.trailing, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.brandName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
//                    Spacer()
//                    
//                    Image(systemName: "heart")
                }
                
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Jumlah Antrian: 50")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.red, lineWidth: 0.7)
                        )
                    
                    Text("Ambil Antrian >")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.red, lineWidth: 0.7)
                        )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.white))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Preview
#Preview {
    // 1. Create sample brand detail
    let sampleBrandDetail = BrandDetail(
        name: "Brand X",
        description: "Premium beauty products with natural ingredients",
        images: ["brand1", "brand2", "brand3"],
        flashSaleSchedule: "12:00 - 14:00",
        products: [
            Product(name: "Lipstick Set", description: "Matte finish, 6 colors", image: "lipstick"),
            Product(name: "Foundation", description: "Full coverage, 10 shades", image: "foundation")
        ]
    )
    
    // 2. Create sample flash sale event
    let sampleEvent = FlashSaleEvent(
        brandName: "Brand X",
        description: "Special discount 50% for all products",
        startTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!,
        endTime: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
        date: Date(),
        brandDetail: sampleBrandDetail
    )
    
    // 3. Return the view with sample data
    return FlashSaleItemView(event: sampleEvent)
        .padding()
        .background(Color(.systemGray6)) // Background to see the shadow effect
}
