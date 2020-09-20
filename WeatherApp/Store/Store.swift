//
//  Store.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine

typealias WeatherPoint = (Town, Weather)

enum Store {

    @Storage(key: .towns, defaultValue: [])
    private static var listOfSavedTowns: [Town]
    @Storage(key: .isFirstLaunch, defaultValue: true)
    private static var isFirstLaunch: Bool
    
    private static var towns: [Town] = []
    private static var townDetails: Town?
    private static var weatherStorage = [UUID: Weather]()
    
    private static func write(towns: [Town]) {
        DispatchQueue.global().async {
            listOfSavedTowns = towns
        }
    }
    
    private static func read(completion: ([Town]) -> Void) {
        towns = isFirstLaunch ? sampleData.shuffled() : listOfSavedTowns
        if isFirstLaunch {
            write(towns: towns)
            isFirstLaunch.toggle()
        }
        completion(towns)
    }
    
}

extension Store {
    
    static func restoreListTowns() -> AnyPublisher<[Town], Error> {
        Future<[Town], Error> { promise in
            read { towns in
                promise(.success(towns))
                promise(.failure(AppError.Store.restoreFailure))
            }
        }.eraseToAnyPublisher()
    }

    static func rowsWillMove(source: IndexSet, destination: Int) -> AnyPublisher<[Town], Error> {
        Future<[Town], Error> { promise in
            towns.move(fromOffsets: source, toOffset: destination)
            write(towns: towns)
            promise(.success(towns))
            promise(.failure(AppError.Store.moveFailure))
        }.eraseToAnyPublisher()
    }
    
    static func rowWillRemove(at index: Int) -> AnyPublisher<[Town], Error> {
        Future<[Town], Error> { promise in
            weatherStorage[towns[index].id] = nil
            towns.remove(at: index)
            write(towns: towns)
            promise(.success(towns))
            promise(.failure(AppError.Store.removeFailure))
        }.eraseToAnyPublisher()
    }
    
    static func rowWillAdded(_ townID: UUID) -> AnyPublisher<(Town, Weather, Bool), Error> {
        let addPublisher = Future<(Town, Weather), Error> { promise in
            if let town = townDetails, town.id == townID, let weather = weatherStorage[townID] {
                towns.insert(town, at: 0)
                write(towns: towns)
                promise(.success((town, weather)))
            } else {
                promise(.failure(AppError.Store.appendFailure))
            }
        }.eraseToAnyPublisher()
        
        let checkInList: (Town, Weather) -> (Town, Weather, Bool) = { town, weather in
            let isOnList = towns.contains { $0 == town }
            return (town, weather, isOnList)
        }
        
        return addPublisher
            .map(checkInList)
            .eraseToAnyPublisher()
    }
    
    static func itemWillRemove(with townID: UUID) -> AnyPublisher<(Town, Weather, Bool), Error> {
        let removerPublisher: (Town) -> AnyPublisher<(Town, Weather, Bool), Error> = { town in
            Future<(Town, Weather, Bool), Error> { promise in
                guard let weather = weatherStorage[townID],
                    let index = towns.firstIndex(of: town)
                    else { return promise(.failure(AppError.Store.removeFailure)) }
                towns.remove(at: index)
                write(towns: towns)
                let isOnList = towns.contains { $0 == town }
                return promise(.success((town, weather, isOnList)))
            }.eraseToAnyPublisher()
        }
        
        return townPublisher(townID)
                .flatMap(removerPublisher)
                .eraseToAnyPublisher()
    }
    
    static func getWeather(by townID: UUID) -> AnyPublisher<Weather, Error> {
        
        if let weather = weatherStorage[townID] {
            return Just(weather)
                .mapError{ _ in AppError.Store.notFound }
                .eraseToAnyPublisher()
        }
        
        let getWeather = { (town: Town) in
            WeatherAPI.getWeather(by: town.coordinate)
                .removeDuplicates()
                .map(Weather.init)
        }

        return  townPublisher(townID)
            .flatMap(getWeather)
            .handleEvents(receiveOutput: { weatherStorage[townID] = $0 })
            .eraseToAnyPublisher()
    }

    static func searchTown(by name: String) -> AnyPublisher<Town, Error> {
        
        let alreadyOnList: (Town) -> Town = {
            let town = towns.first(where: { $0.name.lowercased() == name.lowercased() })
            return town == nil ? $0 : town!
        }
        
        return CoordinateAPI.getCoordinate(by: name)
            .handleEvents(receiveOutput: { _ in townDetails = nil })
            .map { Town(name: $0.0, coordinate: $0.1) }
            .handleEvents(receiveOutput: { townDetails = $0 })
            .map (alreadyOnList)
            .eraseToAnyPublisher()
    }
    
    static func getDetails(by townID: UUID) -> AnyPublisher<(Town, Weather, Bool), Error> {
        
        var weatherPublisher: AnyPublisher<Weather, Error> {
            guard let weather = weatherStorage[townID]
                else { return getWeather(by: townID) }
            return Just(weather)
                .mapError{ _ in AppError.Store.notFound }
                .eraseToAnyPublisher()
        }
        
        var checkInList: AnyPublisher<Bool, Error> {
            Just(towns.contains { $0.id == townID })
                .mapError { _ in AppError.Store.notFound }
                .eraseToAnyPublisher()
        }
        
        return townPublisher(townID)
            .handleEvents(receiveOutput: { townDetails = $0 })
            .combineLatest(weatherPublisher, checkInList)
            .eraseToAnyPublisher()
    }

    private static func townPublisher(_ townID: UUID) -> AnyPublisher<Town, Error> {
        Future { promise in
            guard let town = towns.first(where: { $0.id == townID }) ?? townDetails
                else { return promise(.failure(AppError.Store.notFound)) }
            return promise(.success(town))
        }.eraseToAnyPublisher()
    }
    
}
