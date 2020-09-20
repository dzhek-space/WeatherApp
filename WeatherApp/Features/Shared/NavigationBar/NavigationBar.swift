//
//  NavigationBar.swift
//  WeatherApp
//
//  Created by Dzhek on 16.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI

typealias ButtonProperties = (action: () -> Void, state: Bool)

struct NavigationBar: View {
    
    let kind: Kind
    let trailingButtonProperties: ButtonProperties
    let isHiddenTrailingButton: Bool
    
    var body: some View {
        HStack {
            LeadingButton(kind: kind)
            Spacer()
            TrailingButton(kind: kind, properties: trailingButtonProperties, isHidden: isHiddenTrailingButton)
        }
        .frame(maxWidth: .infinity, maxHeight: 44, alignment: .top)
    }
    
    init(kind: NavigationBar.Kind, trailingButtonProperties: ButtonProperties, isHiddenTrailingButton: Bool = false) {
        self.kind = kind
        self.trailingButtonProperties = trailingButtonProperties
        self.isHiddenTrailingButton = isHiddenTrailingButton
    }
    
}


// MARK: - Nested Views

extension NavigationBar {
    
    struct LeadingButton: View {
        
        @Environment(\.presentationMode) var presentMode
        let kind: Kind
         
        var body: some View {
            Button(action: { [presentMode] in presentMode.wrappedValue.dismiss() },
                   label: { icon })
                .buttonStyle(MyButtonStyle())
        }
        
        private var icon: some View {
            switch kind {
                case .editList: return Color.clear.eraseToAnyView()
                case .details: return NavigationBar.Icon(name: "list.bullet").eraseToAnyView()
            }
        }
    }
    
    struct TrailingButton: View {
        
        let kind: Kind
        let action: () -> Void
        let status: Bool
        let isHidden: Bool
        
        var body: some View {
            Button(action: action, label: { icon })
                .buttonStyle(MyButtonStyle())
                .opacity(isHidden ? 0 : 1)
        }
        
        private var icon: some View {
            switch kind {
                case .editList: return NavigationBar.Icon(name: status ? "checkmark" : "list.bullet")
                case .details: return NavigationBar.Icon(name: status ? "trash" : "plus")
            }
        }
        
        init(kind: Kind, properties: ButtonProperties, isHidden: Bool = false) {
            self.kind = kind
            self.isHidden = isHidden
            action = properties.action
            status = properties.state
        }
        
    }
    
    struct Icon: View {
        
        let name: String
        @State var opacity = 0.0
        
        var body: some View {
            Image(systemName: name)
                .font(Typography.mediumIcon)
                .foregroundColor(Palette.secondary)
                .frame(width: 44, height: 44, alignment: .center)
        }
    }
    
    enum Kind {
        case editList
        case details
    }
    
}

struct MyButtonStyle: ButtonStyle {
    public func makeBody(configuration: MyButtonStyle.Configuration) -> some View {
        
        configuration.label
            .compositingGroup()
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
    }
}


// MARK: - Preview Provider

#if DEBUG
struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationBar(kind: .editList, trailingButtonProperties: (action: {}, state: false), isHiddenTrailingButton: false)
            NavigationBar(kind: .details, trailingButtonProperties: (action: {}, state: true), isHiddenTrailingButton: false)
            NavigationBar.LeadingButton(kind: .details)
            NavigationBar.TrailingButton(kind: .details, properties: (action: {}, state: true))
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
