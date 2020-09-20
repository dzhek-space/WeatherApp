//
//  Coordinate.swift
//  WeatherApp
//
//  Created by Dzhek on 11.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}


extension Coordinate {
    
    init?(_ value: [Double]) {
        latitude = value[1]
        longitude = value[0]
    }
}
