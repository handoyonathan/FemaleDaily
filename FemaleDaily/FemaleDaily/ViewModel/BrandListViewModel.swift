//
//  BrandListViewModel.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 23/07/25.
//

import Foundation
import UIKit

class BrandListViewModel: ObservableObject{
    @Published var searchText: String = ""
    private let brands = DummyBrands.data
    
    var filteredBrands: [Brand] {
        if searchText.isEmpty {
            return brands
        } else {
            return brands.filter { $0.namaBrand.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
