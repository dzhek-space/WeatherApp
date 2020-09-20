//
//  Row.swift
//  WeatherApp
//
//  Created by Dzhek on 09.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI


struct Row: View {
    
    @State var town: TownList.Model
    let isCompactMode: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(town.title)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !isCompactMode {
                    WeatherLoaderView(viewModel: WeatherLoader(townID: town.id))
                        .animation(Animation.easeInOut.speed(1.7))
                }
            }
            .padding(.vertical, 24)
            Divider()
                .background(Palette.secondary)
                .opacity(0.5)
        }
        .padding(.horizontal)
    }
}


// MARK: - Preview Provider

#if DEBUG
struct Row_Previews: PreviewProvider {
    static var previews: some View {
        Row(town: TownList.Model(sampleData[7]), isCompactMode: false)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
