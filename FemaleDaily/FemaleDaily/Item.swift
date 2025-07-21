//
//  Item.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 21/07/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
