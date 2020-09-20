//
//  AppError.swift
//  WeatherApp
//
//  Created by Dzhek on 11.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation


enum AppError {
    
    enum Store: Error {
        case restoreFailure
        case moveFailure
        case removeFailure
        case appendFailure
        case notFound
    }
    
    enum Network: Error {
        case url(URLError?)
        case decode
        case unknown(Error)
    }
    
    enum Search: Error {
        case failure
    }
}
