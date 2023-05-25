//
//  LogInViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import Foundation
import SwiftUI

class LogInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var feedbackMessage: String?
    @Published var profileImage: UIImage?
    @Published var loginRegisterPressed = false
    
    @MainActor
    func registerNewAccount() async {
        do {
            loginRegisterPressed = true
            let result = try await FirebaseManager.shared.auth
                .createUser(withEmail: email, password: password)
            print("Successfully created user: \(result.user.uid)")
//            self.feedbackMessage = "Successfully created user"
            FirebaseManager.shared.loggedInUid = result.user.uid
            if let url = await storeProfileImage() {
                await storeUserInformation(profileImageUrl: url)
                loginRegisterPressed = false
            }
            loginRegisterPressed = false
        } catch {
            print("Failed to create user: \(error)")
            self.feedbackMessage = "Failed to create user: \(error.localizedDescription)"
            loginRegisterPressed = false

        }
    }
    
    @MainActor
    func loginAccount() async {
        do {
            let result = try await FirebaseManager.shared.auth
                .signIn(withEmail: email, password: password)
            print("Successfully signed in user: \(result.user.uid)")
            FirebaseManager.shared.loggedInUid = result.user.uid
        } catch {
            print("Failed to sign into used user: \(error)")
            self.feedbackMessage = "Failed to sign into user: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func storeProfileImage() async -> URL? {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return nil }
        
        do {
            let ref = FirebaseManager.shared.storage
                .reference(withPath: uid)
            
            guard let imageData = self.profileImage?.jpegData(compressionQuality: 0.2) else { return nil }
            
            let _ = try await ref.putDataAsync(imageData)
            return try await ref.downloadURL()
            
        } catch {
            print("Failed to push profile image to storage: \(error)")
            return nil
        }
    }
    
    @MainActor
    func storeUserInformation(profileImageUrl: URL) async {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.email: email,
                        FirebaseConstants.uid: uid,
                        FirebaseConstants.profileImageUrl: profileImageUrl.absoluteString]
        do {
            try await FirebaseManager.shared.firestore
                .collection("users")
                .document(uid)
                .setData(userData)
            print("successfully saved user data to firestore")
        } catch {
            print(error)
        }
    }
    
    
}
