//
//  SearchView.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI
import Combine


struct SearchView: View {
    
    @ObservedObject var viewModel: Search
    
    @State var text: String = ""
    @State var isEdited = false
    @State var town: Search.Model
    let setDetaileLink: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SearchField(viewModel: viewModel,
                        text: $text,
                        isEdited: $isEdited)
                searchResult
                    .animation(.default)
        }
        .padding()
    }
    
    private var searchResult: some View {
        switch viewModel.state {
            case .error:
                return BadSearch(townName: text)
                    .padding(.top, 6)
                    .eraseToAnyView()
            case let .loaded(town):
                setDetaileLink(town.id)
                fallthrough
            default:
                return EmptyView().eraseToAnyView()
        }
    }
    
}


// MARK: - Nested Views

extension SearchView {
    
    struct SearchField: View {
        
        let viewModel: Search
        @Binding var text: String
        @Binding var isEdited: Bool
        
        var body: some View {
            HStack {
                TextField("Найти город...",
                          text: $text,
                          onEditingChanged: { self.isEdited = $0 },
                          onCommit: showWeatherPoint)
                    .font(.headline)
                    .padding(.leading, 8)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .accentColor(Palette.secondary)
                    .foregroundColor(Palette.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Palette.transparentSystemGray6))
                    .overlay(SearchView.ClearButton(isHidden: text.isEmpty,
                                                    action: clearTextField))
                    .onTapGesture { self.isEdited = true }
                    .animation(.default)
                
                if isEdited || !text.isEmpty {
                    SearchView.CancelButton(action: cancelSearch)
                }
            }
            .onDisappear(perform: self.cancelSearch)
        }
        
        private func clearTextField() {
            self.text = ""
            viewModel.send(.onCancel)
        }
        
        private func cancelSearch() {
            clearTextField()
            isEdited = false
            UIApplication.shared.endEditing()
        }
        
        private func showWeatherPoint() {
            let value = text
            viewModel.send(.onCommit(value))
            UIApplication.shared.endEditing()
        }
        
    }

    struct CancelButton: View {
        
        @State private var cancelSearchButtonOpacity: Double = 0
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: "multiply")
                    .font(Typography.tableBody)
                    .foregroundColor(Palette.secondary)
                    .padding()
                    .background(Circle().fill(Palette.transparentSystemGray6))
            }
            .scaleEffect(isHiddenButton ? 0.5 : 1)
            .opacity(isHiddenButton ? 0.3 : 1)
            .onAppear(perform: showButton)
            .onDisappear(perform: hideButton)
            .opacity(cancelSearchButtonOpacity)
            .animation(Animation.default.delay(0.15))
        }
        
        private var isHiddenButton: Bool { !(cancelSearchButtonOpacity != 0) }
        private func showButton() { cancelSearchButtonOpacity = 1 }
        private func hideButton() { cancelSearchButtonOpacity = 0 }
        
    }
    
    struct ClearButton: View {
        
        let isHidden: Bool
        let clearTextField: () -> Void
        
        var body: some View {
            HStack {
                Spacer()
                Button(action: clearTextField) {
                    Image(systemName: "multiply.circle.fill")
                        .font(.headline)
                        .foregroundColor(Palette.secondary.opacity(0.6))
                        .padding(.horizontal)
                }
                .opacity(isHidden ? 0 : 1)
                .animation(.linear)
                .scaleEffect(isHidden ? 0.1 : 1)
                .animation(
                    Animation
                        .spring(response: 0.3, dampingFraction: 0.5)
                        .delay(0.1)
                )
                
            }
        }
        
        init(isHidden: Bool, action: @escaping () -> Void) {
            self.clearTextField = action
            self.isHidden = isHidden
        }
    }
    
    struct BadSearch: View {
        
        let townName: String
        @State var opacity = 0.0
        
        var body: some View {
            VStack {
                HStack {
                    Text("🤷‍♂️")
                        .font(Typography.largeIcon)
                        .padding(8)
                    VStack {
                        Text("B городе ")
                            + Text("«\(townName)»")
                                .fontWeight(.medium)
                        Text("хорошая погода,")
                            .lineLimit(1)
                        Text("но это не точно...")
                            .lineLimit(1)
                    }
                }
                Text("Проверить не получилось")
                    .padding(.bottom, 2)
                Divider()
                    .background(Palette.secondary)
                    .opacity(0.5)
                    .scaleEffect(0.8)
            }
            .opacity(opacity)
            .onAppear { self.opacity = 1 }
        }
    }
    
}


// MARK: - Preview Provider

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SearchView(viewModel: Search(), town: Search.Model(sampleData[2]), setDetaileLink: { _ in })
            SearchView.BadSearch(townName: "XXX")
        }
        .environment(\.colorScheme, .dark)
        .background(Color.gray)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
