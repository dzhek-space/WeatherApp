//
//  Detailed.swift
//  WeatherApp
//
//  Created by Dzhek on 13.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine


final class Detailed: ObservableObject {
    
    @Published private(set) var state: State
    
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init(id: UUID) {
        state = .idle(id)
        
        Publishers
            .system(initial: state,
                    reduce: Self.reduce,
                    scheduler: RunLoop.main,
                    feedbacks: [
                        Self.dataDidReceived(),
                        Self.needAdd(input: input.eraseToAnyPublisher()),
                        Self.needExclude(input: input.eraseToAnyPublisher()),
                        Self.userInput(input: input.eraseToAnyPublisher()),
            ])
            .sink { [weak self] in self?.state = $0 }
            .store(in: &bag)
    }
    
    deinit {
        bag.removeAll()
    }
    
    func send(_ event: Event) {
        input.send(event)
    }
    
}


extension Detailed {
    
    static func reduce(_ state: State, _ event: Event) -> State {
        switch (state, event) {
            case (let .idle(id), .onAppear):
                return .receive(id)
            case (.receive, let .onChanged(details)):
                return .dataUpdated(details)
            case (.dataUpdated, let .onChanged(details)):
                return .dataUpdated(details)
            case (_, .onFailed):
                return .error
            
            default:
                return state
        }
    }
    
    static func dataDidReceived() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case let .receive(id) = state else { return Empty().eraseToAnyPublisher() }
            return Store.getDetails(by: id)
                .map(Model.init)
                .map(Event.onChanged)
                .catch { _ in Just(Event.onFailed) }
                .eraseToAnyPublisher()
        }
    }
    
    static func needAdd(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback<State, Event> { _ in
            input.flatMap { event -> AnyPublisher<Event, Never>  in
                guard case .addToList(let id) = event
                    else { return Empty().eraseToAnyPublisher() }
                return Store.rowWillAdded(id)
                    .map(Model.init)
                    .map(Event.onChanged)
                    .catch { _ in Just(Event.onFailed) }
                    .eraseToAnyPublisher()
            }
        }
    }
    
    static func needExclude(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback<State, Event> { _ in
            input.flatMap { event -> AnyPublisher<Event, Never>  in
                guard case .exclude(let id) = event
                    else { return Empty().eraseToAnyPublisher() }
                return Store.itemWillRemove(with: id)
                    .map(Model.init)
                    .map(Event.onChanged)
                    .catch { _ in Just(Event.onFailed) }
                    .eraseToAnyPublisher()
            }
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback(run: { _ in return input })
    }
    
}


// MARK: - Nested Types

extension Detailed {
    
    enum State {
        case idle(UUID)
        case receive(UUID)
        case dataUpdated(Model)
        case error
    }
    
    enum Event {
        case onAppear
        case onChanged(Model)
        case addToList(UUID)
        case exclude(UUID)
        case onFailed
    }
    
    struct Model {
        let id: UUID
        let isOnList: Bool
        let townName: String
        let date: String
        let temperature: String
        let feelsLike: String
        let condition: String
        let windSpeed: String
        let windDirection: String
        let pressure: String
        let humidity: String
        let sunriseTime: String
        let sunsetTime: String
        
        init(town: Town, weather: Weather, isOnList: Bool) {
            self.id = town.id
            self.isOnList = isOnList
            self.townName = town.name
            self.date = Date().asTodayStringRU
            self.temperature = weather.temp
            self.feelsLike = "Ощущается как \(weather.feelsLike)"
            self.condition = weather.condition.associatedSFSymbolsName
            self.windSpeed = weather.windSpeed + " м/с"
            self.windDirection = weather.windDirection.associatedString
            self.pressure = weather.pressure + " мм"
            self.humidity = weather.humidity + " %"
            self.sunriseTime = weather.sunriseTime
            self.sunsetTime = weather.sunsetTime
        }
    }
    
}
