//
//  Request.swift
//  WeatherApp
//
//  Created by Dzhek on 09.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
}


protocol Request {
    
    var method: HTTPMethod { get }
    var scheme: String { get }
    var path: String { get }
    var host: String { get }
    var queryItems: [URLQueryItem] { get }
    
    func configure() -> URLRequest
    
}


extension Request {
    
    var method: HTTPMethod { return .get }

    var baseRequest: URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url
            else { preconditionFailure("Invalid url components") }
    
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        return request
    }
    
}
