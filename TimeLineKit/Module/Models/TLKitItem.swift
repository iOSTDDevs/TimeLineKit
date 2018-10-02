//
//  TMKItem.swift
//  TimeLineKit
//
//  Created by Daniel Rocha on 01/10/18.
//  Copyright © 2018 Daniel Rocha. All rights reserved.
//

import Foundation

public struct TLKitItem {
    
    var id: Int
    var defaultItem: Bool
    var description: String
    var unique: Bool
    
    public init(id: Int, defaultItem: Bool, description: String, unique: Bool) {
        self.id = id
        self.defaultItem = defaultItem
        self.description = description
        self.unique = unique
    }
    
}
