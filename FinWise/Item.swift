//
//  Item.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
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
