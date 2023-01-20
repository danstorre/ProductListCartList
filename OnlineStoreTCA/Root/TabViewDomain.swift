//
//  RootDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import Foundation
import ComposableArchitecture

struct TabViewDomain {
    struct State: Equatable {
        var selectedTab = Tab.products
    }
    
    enum Tab {
        case products
        case profile
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
    }
    
    struct Environment {}
    
    static let reducer = Reducer<
        State, Action, Environment
    >.init { state, action, environment in
        switch action {
        case .tabSelected(let tab):
            state.selectedTab = tab
            return .none
        }
    }
}
