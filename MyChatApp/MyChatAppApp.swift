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
                    .onTapGesture(count: 5) {
                        do {
                            try FirebaseManager.shared.auth.signOut()
                            print("Signed out")
                        } catch {
                            print("error signing out")
                        }
                    }
            }
            .environmentObject(routerManager)
            .task {
                if let _ = FirebaseManager.shared.auth.currentUser {
                    print("checking current user")
                    await FirebaseManager.getUserInformation()
                    print("received current user: \(FirebaseManager.shared.loggedInUser)")
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
