//
//  BrandDetail.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import Foundation

struct BrandDetail {
    let name: String
    let description: String
    let images: [String] // Nama gambar atau URL
    let flashSaleSchedule: String
    let products: [Product]
}

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let image: String
}
