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
    
    init() {
        mainView = Root.createView()
    }
    
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
}
