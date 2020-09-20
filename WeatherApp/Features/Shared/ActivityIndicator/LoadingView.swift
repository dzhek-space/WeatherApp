//
//  LoadingView.swift
//  WeatherApp
//
//  Created by Dzhek on 13.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI


struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            ActivityIndicatorView(size: .large)
            Spacer()
            Spacer()
            Spacer()
        }
    }
}


// MARK: - Preview Provider

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
#endif

