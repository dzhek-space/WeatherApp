//
//  Search.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine


final class Search: ObservableObject {
    
    @Published private(set) var state = State.inactive
    
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init() {
        Publishers
            .system(initial: state,
                    reduce: Self.reduce,
                    scheduler: RunLoop.main,
                    feedbacks: [
                        Self.startSearch(),
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


extension Search {
    
    static func reduce(_ state: State, _ event: Event) -> State {
        switch (state, event) {
            case (_ , .onCancel):
                return .inactive
            case (_ , let .onCommit(text)):
                return .loading(text)
            case (.loading, let .successSearch(town)):
                return .loaded(town)
            case (.loading, .failedSearch):
            return .error
            default: return state
        }
    }
    
    static func startSearch() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case let .loading(text) = state,
                text.trimmingCharacters(in: .whitespaces).count > 0
                else { return Empty().eraseToAnyPublisher() }
            let formatedText = text
                .trimmingCharacters(in: .whitespaces)
            return Store.searchTown(by: formatedText)
                .map(Model.init)
                .map(Event.successSearch)
                .catch{ Just(Event.failedSearch($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback(run: { _ in return input })
    }
    
}


// MARK: - Nested Types

extension Search {
    
    enum State {
        case inactive
        case loading(String)
        case loaded(Model)
        case error
    }
    
    enum Event {
        case onCancel
        case onCommit(String)
        case successSearch(Model)
        case failedSearch(Error)
    }
    
    struct Model: Identifiable {
        let id: UUID
        let title: String
        
        init(_ town: Town) {
            id = town.id
            title = town.name
        }
    }
    
}
