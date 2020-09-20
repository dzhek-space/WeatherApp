//
//  TownListView.swift
//  WeatherApp
//
//  Created by Dzhek on 08.09.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import SwiftUI


struct TownListView: View {
    
    @ObservedObject var viewModel: TownList = TownList()
    @State var editMode: EditMode = .inactive
    @State var isActiveLink = false
    @State var linkID = UUID()
    @State var isOnList = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(RadialGradient(gradient: Palette.coolSkyGradient,
                                         center: UnitPoint(x: 0.8, y: 0), startRadius: 1, endRadius: Screen.height / 1.2))
                    .transformEffect(CGAffineTransform(scaleX: 2, y: 1))
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    NavigationBar(kind: .editList, trailingButtonProperties: (switchEditMode, editMode.isEditing))
                    NavigationLink(destination: DetailedView(viewModel: Detailed(id: linkID), isActiveLink: $isActiveLink), isActive: $isActiveLink) { EmptyView() }
                    Text("Погода в городах")
                        .font(Typography.largeTitle)
                        .lineLimit(1)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SearchView(viewModel: Search(),
                               town: Search.Model(sampleData[2]),
                               setDetaileLink: showDetail)
                        .padding(.horizontal, 8)
                    listOfTowns
                }
                .onAppear(perform: sendEvent)
                .background(Color.clear)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .foregroundColor(Palette.primary)
        
    }
    
    private var listOfTowns: some View {
        switch viewModel.state {
            case .idle:
                return Color.clear.eraseToAnyView()
            case.restore:
                return LoadingView().eraseToAnyView()
            case let .dataUpdated(towns):
                return configureList(with: towns).eraseToAnyView()
            case .error(_):
                return Color.clear.eraseToAnyView()
        }
    }

    private func configureList(with towns: [TownList.Model]) -> some View {
        towns.isEmpty
            ? EmptyList().eraseToAnyView()
            : ListTowns(list: towns,
                         viewModel: viewModel,
                         editMode: editMode,
                         setDetaileLink: showDetail)
                .eraseToAnyView()
    }
    
    
    private func sendEvent() {
        self.viewModel.send(.onAppear)
    }
    
    private func showDetail(by id: UUID) {
        linkID = id
        isActiveLink.toggle()
    }
    
    private func switchEditMode() {
        editMode.toggle()
    }
    
}


// MARK: - Nested Views

extension TownListView {
    
    struct ListTowns: View {
        
        let list: [TownList.Model]
        let viewModel: TownList
        let editMode: EditMode
        let setDetaileLink: (UUID) -> Void
        
        private let rowInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        var body: some View {
            List {
                ForEach(list) { town in
                    Button(action: { self.setDetaileLink(town.id) }) {
                        Row(town: town, isCompactMode: self.editMode.isEditing)
                            .font(Typography.tableBody)
                    }
                    .listRowInsets(self.rowInsets)
                }
                .onMove(perform: swapRows)
                .onDelete(perform: deleteRow)
            }
            .animation(.default)
            .environment(\.editMode, .constant(editMode))
            
        }
        
        private func swapRows(source: IndexSet, destination: Int) {
            viewModel.send(.onMove(source, destination))
        }
        private func deleteRow(indexSet: IndexSet) {
            guard let index = indexSet.first else { return }
            viewModel.send(.onDelete(index))
        }
        
    }

    struct EmptyList: View {
        
        @State var isHidden = true
        
        var body: some View {
            VStack {
                Spacer()
                Spacer()
                Image(systemName: "sun.max")
                    .font(Typography.largeIcon)
                    .padding()
                Text("Список пуст")
                Spacer()
                Spacer()
                Spacer()
            }
            .foregroundColor(Palette.tertiary.opacity(0.5))
            .opacity(isHidden ? 0 : 1)
            .animation(.linear)
            .onAppear{ self.isHidden.toggle() }
            .onDisappear{ self.isHidden.toggle() }
        }
        
    }
    
}


// MARK: - Preview Provider

#if DEBUG
struct TownListViwe_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TownListView(viewModel: TownList(),
                         editMode: .inactive)
            TownListView(viewModel: TownList(),
                         editMode: .inactive)
                .environment(\.colorScheme, .dark)
            TownListView.EmptyList()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
