//
//  OnlineStoreTCAApp.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 04/08/22.
//

import SwiftUI
import ComposableArchitecture

@main
struct OnlineStoreTCAApp: App {
    public var mainView: TabViewContainer
    private var root: Root
    
    init(effectFetchProducts: EffectTask<ProductsContainerDomain.Action>) {
        self.root = Root(effectFetchProducts: effectFetchProducts)
        mainView = root.createMainView()
    }
    
    init() {
        self.root = Root()
        mainView = root.createMainView()
    }
    
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
}
