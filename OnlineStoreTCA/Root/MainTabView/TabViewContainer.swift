//
//  RootView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import SwiftUI
import ComposableArchitecture

struct TabViewContainer: View {
    let store: Store<TabViewDomain.State, TabViewDomain.Action>
    @State var productListStore: Store<ProductListDomain.State,ProductListDomain.Action>
    @State var profileStore: Store<ProfileDomain.State, ProfileDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: \.selectedTab,
                    send: TabViewDomain.Action.tabSelected
                )
            ) {
                ProductListView(
                    store: productListStore
                )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Products")
                }
                .tag(TabViewDomain.Tab.products)
                ProfileView(
                    store: profileStore
                )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(TabViewDomain.Tab.profile)
            }
        }
    }
}
