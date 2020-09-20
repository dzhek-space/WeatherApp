//
//  WeatherLoader.swift
//  WeatherApp
//
//  Created by Dzhek on 10.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine


final class WeatherLoader: ObservableObject {
    
    @Published private(set) var state: State
    private let townID: UUID
    
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init(townID: UUID) {
        self.townID = townID
        self.state = .loading(townID)
        Publishers
            .system(initial: state,
                    reduce: Self.reduce,
                    scheduler: RunLoop.main,
                    feedbacks: [
                        Self.dataDidReceived(),
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

extension WeatherLoader {
    
    static func reduce(_ state: State, _ event: Event) -> State {
        switch (state, event) {
            case (.loading, .onAppear):
                return state
            case (.loading, let .onLoaded(data)):
                return .loaded(data)
            case (.loading, let .onFailed(data)):
                return .failed(data)
            case (let .failed(data), _):
                return .loading(data.id)
            default: return state
            
        }
    }
    
    static func dataDidReceived() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading(let id) = state else { return Empty().eraseToAnyPublisher() }
            return Store.getWeather(by: id)
                .map{ Model(townID: id, weather: $0) }
                .map(Event.onLoaded)
                .catch { _ in Just(Event.onFailed(Model.badLoad)) }
                .eraseToAnyPublisher()
        }
    }
    
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        return Feedback(run: { _ in return input })
    }
}


extension WeatherLoader {
    
    enum State {
        case loading(UUID)
        case loaded(Model)
        case failed(Model)
    }
    
    enum Event {
        case onAppear
        case onLoaded(Model)
        case onFailed(Model)
    }
    
    struct Model: Identifiable, Hashable {
        let id: UUID
        let iconName: String
        let temperature: String
        
        static let badLoad = Model(id: UUID(),
                                   iconName: SkyCondition.undefined.associatedSFSymbolsName,
                                   temperature: "")
    }

}

extension WeatherLoader.Model {
    
    init(townID: UUID, weather: Weather) {
        id = townID
        iconName = weather.condition.associatedSFSymbolsName
        temperature = weather.temp
    }
    
}
