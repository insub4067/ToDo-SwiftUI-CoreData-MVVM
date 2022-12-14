//
//  ContentView.swift
//  ToDo-SwiftUI
//
//  Created by Kim Insub on 2022/08/02.
//

import SwiftUI
import Combine
import CoreData

struct CategoryListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @ObservedObject var viewModel = CategoryListViewModel()
    @FocusState var isFocused

    let coreDataManager = CoreDataManager()

    init() {
        UITableView.appearance().backgroundColor = UIColor(Color.background)
        UITableViewHeaderFooterView.appearance().tintColor = UIColor(Color.background)

        let navBarAppearance = UINavigationBar.appearance()

        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.accentColor)]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.accentColor)]
        navBarAppearance.barTintColor = UIColor(Color.background)
    }

    var body: some View {

        NavigationView {
            List {
                Section(header: HStack {
                    Text("카테고리 추가")
                        .foregroundColor(Color.textColor)
                        .opacity(0.5)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.vertical, 5)
                    .padding(.leading, 15)
                    .background(Color.background))
                {
                    TextField("입력", text: $viewModel.userInput) {
                        viewModel.didSubmitTextField(context: managedObjectContext)
//                        isFocused = true
                    }
                    .foregroundColor(Color.textColor)
                    .listRowBackground(Color.background)
                    .focused($isFocused)
                }

                Section(header: HStack {
                    Text("카테고리 목록")
                        .foregroundColor(Color.textColor)
                        .opacity(0.5)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.vertical, 5)
                    .padding(.leading, 15)
                    .background(Color.background))
                {
                    ForEach(viewModel.categoryList, id: \.self) { category in

                        ZStack{
                            NavigationLink(category.title ?? "", destination: TodoListView(category: category))
                            .opacity(0)

                            HStack{
                                Image(systemName: "circlebadge.fill")
                                    .resizable()
                                    .frame(width: 3, height: 3)
                                    .foregroundColor(Color.accentColor)
                                Text(category.title ?? "")
                                    .foregroundColor(Color.textColor)
                                    .opacity(0.8)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.background)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            // Category 삭제 버튼
                            Button {
                                viewModel.didTapDeleteButton(category: category)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)

                            // Category 수정 버튼
                            Button {
                                customAlert() { newValue in
                                    viewModel.didTapEditButton(newValue: newValue, category: category, context: managedObjectContext)
                                } secondaryAction: {
                                    print("DEBUG")
                                }
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .tint(.yellow)
                        }
                    }
                    .onMove { indexSet, Int in
//                        for idx in indexSet {
//                            let category = viewModel.categoryList[idx]
//                            print(category.title)
//                        }
                    }
                }
                .navigationBarTitle("카테고리")
                .alert(isPresented: $viewModel.isAlertShowing, content: {
                    Alert(title: Text("삭제 하시겠습니까?"), primaryButton: .destructive(Text("삭제")) {
                        viewModel.didAllowDeletion(context: managedObjectContext)
                    }, secondaryButton: .cancel(Text("취소")))
                })
            }
            .listStyle(.inset)
            .toolbar {
                EditButton()
            }
            .toolbar {
                ToolbarItemGroup(placement: ToolbarItemPlacement.keyboard) {
                    Button("") {}
                    Button {
                        isFocused = false
                    } label: {
                        Text("닫기")
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear(context: managedObjectContext)
        }
    }
}


