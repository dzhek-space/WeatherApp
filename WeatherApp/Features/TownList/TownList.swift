//
//  TownList.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import Combine


final class TownList: ObservableObject {
    
    @Published private(set) var state = State.idle
    
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init() {
        Publishers
            .system(initial: state,
                    reduce: Self.reduce,
                    scheduler: RunLoop.main,
                    feedbacks: [
                        Self.dataDidReceived(),
                        Self.userInput(input: input.eraseToAnyPublisher()),
                        Self.rowsWillMove(input: input.eraseToAnyPublisher()),
                        Self.rowWillRemove(input: input.eraseToAnyPublisher()),
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


extension TownList {
    
    static func reduce(_ state: State, _ event: Event) -> State {
        switch (state, event) {
            case (_ , .onAppear):
                return .restore
            case (_ , let .onChanged(list)):
                return .dataUpdated(list)
            case (_ , let .onFailed(error)):
                return .error(error)
            default:
                return state
        }
    }
    
    static func dataDidReceived() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .restore = state else { return Empty().eraseToAnyPublisher() }
            let configureList: ([Town]) -> [Model] = { $0.map(Model.init) }
            
            return Store.restoreListTowns()
                .map(configureList)
                .map(Event.onChanged)
                .catch { Just(Event.onFailed($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    static func rowsWillMove(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback<State, Event> { _ in
            input.flatMap { event -> AnyPublisher<Event, Never>  in
                guard case .onMove(let source, let destination) = event
                    else { return Empty().eraseToAnyPublisher() }
                
                return Store.rowsWillMove(source: source, destination: destination)
                    .map({ $0.map(Model.init) })
                    .map(Event.onChanged)
                    .catch { Just(Event.onFailed($0)) }
                    .eraseToAnyPublisher()
            }
        }
    }
    
    static func rowWillRemove(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback<State, Event> { _ in
            input.flatMap { event -> AnyPublisher<Event, Never>  in
                guard case .onDelete(let index) = event
                    
                    else { return Empty().eraseToAnyPublisher() }
                return Store.rowWillRemove(at: index)
                    .map({ $0.map(Model.init) })
                    .map(Event.onChanged)
                    .catch { Just(Event.onFailed($0)) }
                    .eraseToAnyPublisher()
            }
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        return Feedback(run: { _ in
            return input
        })
    }
    
}


// MARK: - Nested Types

extension TownList {
    
    enum State {
        case idle
        case restore
        case dataUpdated([Model])
        case error(Error)
    }
    
    enum Event {
        case onAppear
        case onSelect(UUID)
        case onChanged([Model])
        case onMove(IndexSet, Int)
        case onDelete(Int)
        case onFailed(Error)
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
