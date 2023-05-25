//
//  MessageHomeViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import Foundation

class MessageHomeViewModel: ObservableObject {
    @Published var userSignedOut = false
    
    func handleSignOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            userSignedOut = true
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
