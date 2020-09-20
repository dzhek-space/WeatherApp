//
//  Sizes.swift
//  WeatherApp
//
//  Created by Dzhek on 19.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import struct SwiftUI.CGFloat
import class SwiftUI.UIScreen
import class SwiftUI.UIApplication


enum Screen {
    
    static var width: CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
    static var statusBarHeight: CGFloat { UIApplication.shared.statusBarFrame.size.height }
    
}
