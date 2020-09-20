//
//  CoordinateAPI.swift
//  WeatherApp
//
//  Created by Dzhek on 11.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine


// MARK: -

enum CoordinateAPI {
    
    private static var coordinatesDecodingKey: String { "result.address.0.features.0.geometry.geometries.0.coordinates" }
    private static var nameDecodingKey: String { "result.address.0.features.0.properties.title" }
    
    static func getCoordinate(by cityName: String) -> AnyPublisher<(String, Coordinate), Error> {
        let request = CoordinatesRequest(for: cityName).configure()
        
        let resolveCoordinates: (Data) -> AnyPublisher<(String, Coordinate), Error> = { data in
            Future { promise in
                guard let coordinatesValue = resolve(data, keyPath: coordinatesDecodingKey) as [Double]?,
                    let nameValue =  resolve(data, keyPath: nameDecodingKey) as String?,
                    let coordinates = Coordinate(coordinatesValue)
                    else { return promise(.failure(AppError.Network.decode)) }
                return promise(.success((nameValue, coordinates)))
            }.eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .mapError { AppError.Network.url($0 as URLError) }
            .flatMap(resolveCoordinates)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}


// MARK: - Decoding Helper

extension CoordinateAPI {
    
    private static func resolve<T>(_ data: Data, keyPath: String) -> T? {
        let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        var current: Any? = jsonDictionary
        
        keyPath.split(separator: ".").forEach { component in
            if let maybeInt = Int(component), let array = current as? Array<Any> {
                current = array[maybeInt]
            } else if let dictionary = current as? [String: Any] {
                current = dictionary[String(component)]
            }
        }
        return current as? T
    }
    
}


// MARK: -

struct CoordinatesRequest: Request {
    
    var cityName: String
    
    var scheme: String { "http" }
    var host: String { "search.maps.sputnik.ru" }
    var path: String { "/search/addr" }
    var queryItems: [URLQueryItem] {
        [.init(name: "q", value: cityName) ]
    }
    
    init(for cityName: String) {
        self.cityName = cityName
    }
    
    func configure() -> URLRequest {
        return baseRequest
    }
    
}

