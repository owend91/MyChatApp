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
            NavigationStack(path: $routerManager.routes) {
                ProgressView()
                    .navigationDestination(for: Route.self) { $0 }
            }
            .environmentObject(routerManager)
            .task {
                if let _ = FirebaseManager.shared.auth.currentUser {
                    await FirebaseManager.getUserInformation()
                    if let user = FirebaseManager.shared.loggedInUser {
                        routerManager.push(to: .messageHome(loggedInUser: user))
                    }
                } else {
                    routerManager.push(to: .login)
                }
            }
        }
    }
}
