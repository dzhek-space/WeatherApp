//
//  WeatherLoaderView.swift
//  WeatherApp
//
//  Created by Dzhek on 10.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI

struct WeatherLoaderView: View {
    
    @ObservedObject private(set) var viewModel: WeatherLoader
    
    var body: some View {
        content
            .onAppear(perform: sentEvent)
    }
    
    private var content: some View {
        switch viewModel.state {
            case .loading:
                return ActivityIndicatorView(size: .small)
                    .frame(width: 36.0, alignment: .center)
                    .eraseToAnyView()
            case .loaded(let data), .failed(let data):
                return WeatherView(data.temperature, data.iconName)
                    .eraseToAnyView()
        }
    }
    
    private func sentEvent() {
        self.viewModel.send(.onAppear)
    }
}


// MARK: - Nested Views

struct WeatherView: View {
    
    let temperature: String
    let iconName: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text(temperature)
            Image(systemName: iconName)
                .frame(width: 36.0, alignment: .center)
                .offset(x: 0, y: -2)
        }
        .foregroundColor(Palette.secondary)
    }
    
    init(_ temperature: String, _ iconName: String) {
        self.temperature = temperature
        self.iconName = iconName
    }
}


// MARK: - Preview Provider

#if DEBUG
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeatherLoaderView(viewModel: WeatherLoader(townID: UUID()))
            WeatherView("0°", "sun.max")
            WeatherView("-24°", "cloud.heavyrain")
            WeatherView("-24°", "cloud.moon")
        }
        .font(Typography.tableBody)
        .previewLayout(.sizeThatFits)
                .padding()
    }
}
#endif
