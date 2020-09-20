//
//  Extensions.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - App & Environment

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension UIApplication {
    
    var statusBarFrame: CGRect {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?
            .windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
    }
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension EditMode {
    mutating func toggle() {
        self = self.isEditing ? .inactive : .active
    }
}


// MARK: - Visual Effects

struct ListStyleSeparatorNone: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear { UITableView.appearance().separatorStyle = .none }
            .onDisappear { UITableView.appearance().separatorStyle = .none }
    }
}

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

extension SceneDelegate {
    
    func clearAppearance() {
        // List
        let tableAppearance = UITableView.appearance()
        tableAppearance.backgroundColor = .clear
        tableAppearance.tableFooterView = UIView()
        tableAppearance.separatorStyle = .none
        
        let cellAppearance = UITableViewCell.appearance()
        cellAppearance.backgroundColor = .clear
        cellAppearance.selectionStyle = .none
        
        // NavBar
        //        UIBarAppearance().configureWithTransparentBackground()
        //        let navBarAppearance = UINavigationBar.appearance()
        //        navBarAppearance.backgroundColor = .clear
        //        navBarAppearance.setBackgroundImage(UIImage(), for: .default)
        //        navBarAppearance.shadowImage = UIImage()
    }
    
}


// MARK: - Formatters

extension Int {
    var asCelsiusString: String {
        switch self.signum() {
            case 1: return "+\(self)°"
            case -1: return "\(self)°"
            default: return "~\(self)°"
        }
    }
}

extension Date {
    var asTodayStringRU: String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "ru_RU")
        dateformat.dateFormat = "d MMMM"
        return "Сегодня, \(dateformat.string(from: self))"
    }
}
