//
//  LogInViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import Foundation

class LogInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var feedbackMessage: String?
    
    @MainActor
    func registerNewAccount() async {
        do {
            let result = try await FirebaseManager.shared.auth
                .createUser(withEmail: email, password: password)
            print("Successfully created user: \(result.user.uid)")
            self.feedbackMessage = "Successfully created user"
            FirebaseManager.shared.loggedInUid = result.user.uid
        } catch {
            print("Failed to create user: \(error)")
            self.feedbackMessage = "Failed to create user: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func loginAccount() async {
        
        do {
            let result = try await FirebaseManager.shared.auth
                .signIn(withEmail: email, password: password)
            print("Successfully signed in user: \(result.user.uid)")
//            self.feedbackMessage = "Successfully signed in user"
            FirebaseManager.shared.loggedInUid = result.user.uid
        } catch {
            print("Failed to sign into used user: \(error)")
            self.feedbackMessage = "Failed to sign into user: \(error.localizedDescription)"
            
        }
        
    }
}
