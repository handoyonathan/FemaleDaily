//
//  Landmark.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 23/07/25.
//

import SwiftUI

struct Landmark: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String
    let boothID: String
    let relativeX: CGFloat // 0.0 - 1.0 (percentage of image width)
    let relativeY: CGFloat
}
