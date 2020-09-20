//
//  Town.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation


struct Town: Codable, Hashable {
    
    var id = UUID()
    let name: String
    let coordinate: Coordinate
    
    static func == (lhs: Town, rhs: Town) -> Bool {
        lhs.id == rhs.id
    }
    
}
