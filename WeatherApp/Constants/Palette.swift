//
//  Palette.swift
//  WeatherApp
//
//  Created by Dzhek on 14.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import struct SwiftUI.Color
import struct SwiftUI.Gradient

enum Palette {
    
    static let primary = Color("primary")
    static let secondary = Color("secondary")
    static let tertiary = Color("tertiary")
    
    static let сobaltBlue = Color("сobaltBlue")
    static let mayaBlue = Color("mayaBlue")
    static let capri = Color("capri")
    
    static let transparentSystemGray6 = Color(.systemGray6).opacity(0.5)
    
    static let coolSkyGradient = Gradient(colors: [сobaltBlue.opacity(0.9),
                                                   mayaBlue.opacity(0.6),
                                                   capri.opacity(0.3),
                                                   capri.opacity(0)])
    static let arcGradient = Gradient(colors: [capri.opacity(0.2),
                                               capri.opacity(0.5),
                                               mayaBlue.opacity(0.5),
                                               mayaBlue.opacity(0.2)])
}

