//
//  DetailedView.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI


struct DetailedView: View {
    
    @ObservedObject var viewModel: Detailed
    @GestureState private var dragOffset = CGSize.zero
    @Binding var isActiveLink: Bool
    @State private var isOnList: Bool = false
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                navigationBar
                content
                    .padding(.horizontal, 8)
                    .edgesIgnoringSafeArea(.bottom)
                    .onAppear(perform: willOnAppear)
            }
            .foregroundColor(Palette.primary)
        }
        .onDisappear(perform: willOnDisappear)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    private var navigationBar: some View {
        switch viewModel.state {
            case let .dataUpdated(model):
                return NavigationBar(kind: .details, trailingButtonProperties: (trailingButtonAction(model.isOnList), model.isOnList))
                    .eraseToAnyView()
            case .error:
                return NavigationBar(kind: .details, trailingButtonProperties: ({}, false), isHiddenTrailingButton: true)
                    .eraseToAnyView()
            default:
                return NavigationBar(kind: .details, trailingButtonProperties: ({}, false))
                    .eraseToAnyView()
        }
    }
    
    private var content: some View {
        switch viewModel.state {
            case .idle:
                return Color.clear.eraseToAnyView()
            case .receive:
                return LoadingView().eraseToAnyView()
            case let .dataUpdated(model):
                return VStack(alignment: .center) {
                    Header(townName: model.townName, currentDate: model.date)
                    Spacer()
                    MainContent(with: model)
                    Spacer()
                    Spacer()
                    Footer(pressureDetails: ("thermometer", model.pressure, "Давление"),
                           humidityDetails: ("drop.triangle", model.humidity, "Влажность"),
                           windDetails: ("wind", model.windSpeed, model.windDirection))
                        .padding(.bottom, Screen.statusBarHeight)
                }.eraseToAnyView()
            case .error:
                return ErrorView().eraseToAnyView()
        }
    }
    
    private func willOnAppear() {
        self.viewModel.send(.onAppear)
    }
    
    private func willOnDisappear() {
        self.isActiveLink = false
    }
    
    private func trailingButtonAction(_ status: Bool) -> (() -> Void) {
        status ? removeFromList : addToList
    }
    
    private func addToList() {
        guard case .dataUpdated(let model) = viewModel.state
            else { return }
        viewModel.send(.addToList(model.id))
    }
    
    private func removeFromList() {
        guard case .dataUpdated(let model) = viewModel.state
            else { return }
        viewModel.send(.exclude(model.id))
    }
    
}


// MARK: - Nested Views

extension DetailedView {
    
    struct Header: View {
        
        let townName: String
        let currentDate: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(townName)
                    .font(Typography.largeTitle)
                Text(currentDate)
                    .font(Typography.subtitle)
                    .foregroundColor(Palette.tertiary)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
        }
    }
    
    struct MainContent: View {
        
        let iconConditionsName: String
        let temperature: String
        let description: String
        let sunriseTime: String
        let sunsetTime: String
        
        var body: some View {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    DetailedView.Arc(startAngle: .degrees(195), endAngle: .degrees(345), clockwise: false)
                        .stroke(LinearGradient(gradient: Palette.arcGradient, startPoint: .leading, endPoint: .trailing), lineWidth: 0.5)
                        .frame(height: 100)
                        .offset(x: 0, y: 100)
                        .padding(.horizontal, 12)
                        .padding(.bottom)
                        .aspectRatio(1, contentMode: .fill)
                    HStack {
                        VStack {
                            Image(systemName: "sunrise")
                            Text(sunriseTime)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "sunset")
                            Text(sunsetTime)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .font(Typography.headline)
                    .foregroundColor(Palette.tertiary.opacity(0.7))
                }
                VStack {
                    Image(systemName: iconConditionsName)
                        .padding(.top)
                    Text(temperature)
                    Text(description)
                        .font(Typography.subtitle)
                        .foregroundColor(Palette.tertiary)
                }
            }
            .foregroundColor(Palette.secondary)
            .font(Typography.largestIcon)
            .padding()
        }
        
        init(with model: Detailed.Model) {
            iconConditionsName = model.condition
            temperature = model.temperature
            description = model.feelsLike
            sunriseTime = model.sunriseTime
            sunsetTime = model.sunsetTime
        }
    }
    
    struct Footer: View {
        
        typealias Details = (iconName: String, value: String, description: String)
        let pressureDetails: Details
        let humidityDetails: Details
        let windDetails: Details
        
        var body: some View {
            HStack(alignment: .top) {
                DetailBlock(.pressure(pressureDetails))
                Spacer()
                DetailBlock(.humidity(humidityDetails))
                Spacer()
                DetailBlock(.wind(windDetails))
            }
            .padding()
        }
    }
    
    struct ErrorView: View {
        var body: some View {
            VStack {
                Spacer()
                Spacer()
                Text("Информацию не удалось получить.")
                    .padding(.bottom)
                Text("Пожалуйста, проверьте доступность сети интернет.")
                Spacer()
                Spacer()
                Spacer()
            }
            .multilineTextAlignment(.center)
            .foregroundColor(Palette.tertiary)
            .frame(maxWidth: Screen.width * 2/3)
        }
    }
    
    struct Background: View {
        var body: some View {
            Rectangle()
                .fill(RadialGradient(gradient: Palette.coolSkyGradient,
                                     center: UnitPoint(x:  -0.3, y: 0), startRadius: 1, endRadius: Screen.height / 1.2))
                .transformEffect(CGAffineTransform(scaleX: 2, y: 1))
                .opacity(0.9)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    struct Arc: Shape {
        var startAngle: Angle
        var endAngle: Angle
        var clockwise: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            
            return path
        }
    }
    
}

extension DetailedView.Footer {
    
    enum BlockKind {
        case pressure(Details)
        case humidity(Details)
        case wind(Details)
        
    }
    
    struct DetailBlock: View {
        
        let iconName: String
        let value: String
        let description: String
        
        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: iconName)
                    .font(Typography.mediumIcon)
                    .offset(x: 0, y: 10)
                VStack(alignment: .leading) {
                    Text(value)
                        .font(Typography.headline)
                        .foregroundColor(Palette.primary)
                    Text(description.uppercased())
                        .font(Typography.subheadline)
                }
            }
            .foregroundColor(Palette.tertiary)
            .padding(4)
        }
        
        init(_ kind: BlockKind) {
            let params: Details
            switch kind {
                case let .pressure(details): params = details
                case let .humidity(details): params = details
                case let .wind(details): params = details
            }
            iconName = params.iconName
            value = params.value
            description = params.description
        }
    }
    
}


// MARK: - Preview Provider

#if DEBUG
struct DetailedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailedView.Background()
            DetailedView.Header(townName: "Город «N»", currentDate: "Сегодня, 8 тра-та-та")
            DetailedView.Footer(pressureDetails: ("thermometer", "745 mm", "Давление"),
                                humidityDetails: ("drop.triangle", "85 %", "Влажность"),
                                windDetails: ("wind", "5 m/с", "с/восточный"))
            DetailedView.ErrorView()
        }
        
        .previewLayout(.sizeThatFits)
    }
}
#endif

