//
//  AppStorage.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

protocol PropertyList {}
extension Bool: PropertyList {}
extension Array: PropertyList where Element == Town {}

fileprivate let userDefaults = UserDefaults.standard

enum UserDefaultKeys: String {
    case isFirstLaunch
    case towns
}

@propertyWrapper
struct Storage<T: Codable> where T: PropertyList {
    let key: UserDefaultKeys
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            guard let data = userDefaults.object(forKey: key.rawValue) as? Data,
                let restored = try? JSONDecoder().decode(T.self, from: data) as T
                else { return defaultValue }
            return restored
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue)
                else { return }
            userDefaults.set(data, forKey: key.rawValue)
        }
    }

}
