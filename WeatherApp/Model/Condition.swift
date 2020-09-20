//
//  Condition.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

enum SkyCondition {
    case sunMax                
    case moonStars
    case sunMin
    case moon
    case cloudSun
    case cloudMoon
    case cloud
    case cloudFog
    case cloudDrizzle
    case cloudRain
    case cloudHeavyrain
    case cloudSleet
    case cloudSnow
    case cloudHail
    case cloudBolt
    case cloudBoltRain
    case undefined
    
}


extension SkyCondition {
    
    
    /// YandexWeatherAPI keyword initializer
    /// - Parameters:
    ///   - responseString: keyword
    ///   - daytime: value associated with the keywords "d"(true) and "n"(false)
    init(_ responseString: String, _ daytime: Bool) {
        switch responseString {
            case "clear":
                self = daytime ? .sunMax : .moonStars
            case "partly-cloudy":
                self = daytime ? .sunMin : .moon
            case "cloudy":
                self = daytime ? .cloudSun : .cloudMoon
            case "overcast":
                self = .cloud
            case "drizzle":
                self = .cloudFog
            case "light-rain":
                self = .cloudDrizzle
            case "rain", "moderate-rain":
                self = .cloudRain
            case "heavy-rain","continuous-heavy-rain","showers":
                self = .cloudHeavyrain
            case "wet-snow":
                self = .cloudSleet
            case "snow","light-snow","snow-showers":
                self = .cloudSnow
            case "hail":
                self = .cloudHail
            case "thunderstorm":
                self = .cloudBolt
            case "thunderstorm-with-rain","thunderstorm-with-hail":
                self = .cloudBoltRain
            default: self = .undefined
        }
    }
    
    var associatedSFSymbolsName: String {
        switch self {
            case .sunMax: return "sun.max"
            case .moonStars: return "moon.stars"
            case .sunMin: return "sun.min"
            case .moon: return "moon"
            case .cloudSun: return "cloud.sun"
            case .cloudMoon: return "cloud.moon"
            case .cloud: return "cloud"
            case .cloudFog: return "cloud.fog"
            case .cloudDrizzle: return "cloud.drizzle"
            case .cloudRain: return "cloud.rain"
            case .cloudHeavyrain: return "cloud.heavyrain"
            case .cloudSleet: return "cloud.sleet"
            case .cloudSnow: return "cloud.snow"
            case .cloudHail: return "cloud.hail"
            case .cloudBolt: return "cloud.bolt"
            case .cloudBoltRain: return "cloud.bolt.rain"
            case .undefined: return "thermometer.sun"
        }
    }
    
}
