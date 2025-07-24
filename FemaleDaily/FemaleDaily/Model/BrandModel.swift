//
//  BrandModel.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 23/07/25.
//

import Foundation

struct Brand: Identifiable, Equatable{
    let id = UUID()
    let namaBrand: String
    let kategoriBrand: String
    let landmarkBrand: String
}

struct DummyBrands{
    static let data: [Brand] = [
        Brand(namaBrand: "Skintific", kategoriBrand: "Makeup and Skincare", landmarkBrand: "Pond's Glow Tunnel"),
        Brand(namaBrand: "Brand X", kategoriBrand: "Makeup and Skincare", landmarkBrand: "Pond's Glow Tunnel"),
        Brand(namaBrand: "Brand X", kategoriBrand: "Makeup and Skincare", landmarkBrand: "Booth 19"),
        Brand(namaBrand: "Brand X", kategoriBrand: "Makeup and Skincare", landmarkBrand: "Booth 19")
    ]
}
