//
//  OnlineStoreTCAApp.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 04/08/22.
//

import SwiftUI

@main
struct OnlineStoreTCAApp: App {
    var mainView: NewTabViewContainer
    private let root = Root()
    
    init() {
        mainView = root.createNewView()
    }
    
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
}
