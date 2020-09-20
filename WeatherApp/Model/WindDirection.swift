//
//  WindDirection.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation


enum WindDirection {
    case nw
    case n
    case ne
    case e
    case se
    case s
    case sw
    case w
    case с
    case undefined
    
}


extension WindDirection {
    
    /// YandexWeatherAPI keyword initializer
    /// - Parameter responseString: keyword
    init(_ responseString: String) {
        switch responseString {
            case "nw":  self = .nw
            case "n":   self = .n
            case "ne":  self = .ne
            case "e":   self = .e
            case "se":  self = .se
            case "s":   self = .s
            case "sw":  self = .sw
            case "w":   self = .w
            case "с":   self = .с
            default: self = .undefined
        }
    }
    
    var associatedString: String {
        switch self {
            case .nw: return "северо-\nзападный"
            case .n:  return "северный"
            case .ne: return "северо-\nвосточный"
            case .e:  return "восточный"
            case .se: return "юго-\nвосточный"
            case .s:  return "южный"
            case .sw: return "юго-\nзападный"
            case .w:  return "западный"
            case .с:  return "штиль"
            case .undefined: return "нет данных"
        }
    }
    
}
