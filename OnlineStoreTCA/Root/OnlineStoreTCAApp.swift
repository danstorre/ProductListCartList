//
//  OnlineStoreTCAApp.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 04/08/22.
//

import SwiftUI

@main
struct OnlineStoreTCAApp: App {
    var mainView: TabViewContainer
    private let root = Root()
    
    init() {
        mainView = root.createMainView()
    }
    
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
}
