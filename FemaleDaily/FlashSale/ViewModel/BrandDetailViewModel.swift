//
//  BrandDetailViewModel.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

class BrandDetailViewModel: ObservableObject {
    @Published var currentImageIndex = 0
    let brand: BrandDetail
    
    init(brand: BrandDetail) {
        self.brand = brand
    }
    
    func nextImage() {
        currentImageIndex = (currentImageIndex + 1) % brand.images.count
    }
}
