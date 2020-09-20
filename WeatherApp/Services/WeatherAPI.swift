//
//  WeatherAPI.swift
//  WeatherApp
//
//  Created by Dzhek on 09.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine

/// Your personal key for Yandex.Weather API
fileprivate let yaKey = "6abef388-e0b4-4ad2-96aa-4ddf8f4f0414"

enum WeatherAPI {
    
    static func getWeather(by coordinate: Coordinate) -> AnyPublisher<WeatherAPI.DTO, Error> {
        let request = WeatherRequest(for: coordinate).configure()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: WeatherAPI.DTO.self, decoder: decoder)
            .mapError { error -> AppError.Network in
                switch error {
                    case is DecodingError: return AppError.Network.decode
                    case is URLError: return AppError.Network.url(error as? URLError)
                    default: return AppError.Network.unknown(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}


struct WeatherRequest: Request {
    
    let coordinate: Coordinate
    
    var scheme: String { "https" }
    var host: String { "api.weather.yandex.ru" }
    var path: String { "/v2/forecast" }
    var queryItems: [URLQueryItem] {[
        .init(name: "lat", value: "\(coordinate.latitude)"),
        .init(name: "lon", value: "\(coordinate.longitude)"),
        .init(name: "limit", value: "2"),
        .init(name: "hours", value: "false"),
        .init(name: "extra", value: "true")
        ]}
    
    init(for coordinate: Coordinate) {
        self.coordinate = coordinate
    }
    
    func configure() -> URLRequest {
        var request = baseRequest
        request.addValue("\(yaKey)", forHTTPHeaderField: "X-Yandex-API-Key")
        return request
    }

}


// MARK: - WeatherDTO for Yandex Weather API
extension WeatherAPI {
    
    struct DTO: Decodable, Equatable {
        let fact: Fact
        let forecasts: [Forecast]
    }
    
    // MARK: - Fact
    struct Fact: Decodable, Equatable {
        let temp: Int
        let feelsLike: Int
        let condition: String
        let windSpeed: Double
        let windDir: String
        let pressureMm: Int
        let humidity: Int
        let daytime: String
    }
    
    // MARK: - Forecast
    struct Forecast: Decodable, Equatable {
        let sunrise: String
        let sunset: String
    }
}
