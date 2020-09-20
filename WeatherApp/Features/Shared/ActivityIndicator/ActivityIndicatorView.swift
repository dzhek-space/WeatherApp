//
//  ActivityIndicatorView.swift
//  WeatherApp
//
//  Created by Dzhek on 10.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI


struct ActivityIndicatorView: View {
    
    @State private var isAnimating = false
    private var start: Animation { Animation.easeInOut(duration: 1.0).speed(speed) }
    private var cycle: Animation { Animation.linear(duration: 2.0).speed(speed)
        .repeatForever(autoreverses: false)
    }
    var size: ActivityIndicatorView.Size
    private var speed: Double { size == .small ? 0.8 : 0.5 }
    
    var body: some View {
        Image(systemName: "sun.max")
            .font(.system(size: size.rawValue, weight: size.weight))
            .foregroundColor(Palette.tertiary.opacity(0.7))
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
            .animation(isAnimating ? cycle : .default)
            .opacity(isAnimating ? 1 : 0)
            .scaleEffect(isAnimating ? 1 : 0.6)
            .animation(isAnimating ? start : .default)
            .onAppear { self.isAnimating = true }
            .onDisappear { self.isAnimating = false }
    }
    
}


extension ActivityIndicatorView {
    
    enum Size: CGFloat {
        case small = 24
        case large = 48
        
        var weight: Font.Weight {
            switch self {
                case .small: return .regular
                case .large: return .thin
            }
        }
    }
    
}


// MARK: - Preview Provider

#if DEBUG
struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView(size: .small)
    }
}
#endif
