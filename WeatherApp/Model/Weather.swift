//
//  Weather.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct Weather {
    
    let temp: String
    let feelsLike: String
    let condition: SkyCondition
    let windSpeed: String
    let windDirection: WindDirection
    let pressure: String
    let humidity: String
    let sunriseTime: String
    let sunsetTime: String
    
}


extension Weather {
    
    init(_ response: WeatherAPI.DTO) {
        temp =  response.fact.temp.asCelsiusString
        feelsLike = response.fact.feelsLike.asCelsiusString
        let daytime = response.fact.daytime == "n" ? false : true
        condition = SkyCondition(response.fact.condition, daytime)
        windSpeed = "\(response.fact.windSpeed)"
        windDirection = WindDirection(response.fact.windDir)
        pressure = "\(response.fact.pressureMm)"
        humidity = "\(response.fact.humidity)"
        sunriseTime = response.forecasts.first?.sunrise ?? "--"
        sunsetTime = response.forecasts.first?.sunset ?? "--"
    }
    
}

