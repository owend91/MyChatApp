//
//  MyChatAppApp.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI

@main
struct MyChatAppApp: App {
    @StateObject private var routerManager = NavigationRouter()
    var body: some Scene {
        WindowGroup {
            LogInView()
                .environmentObject(routerManager)
        }
    }
}
