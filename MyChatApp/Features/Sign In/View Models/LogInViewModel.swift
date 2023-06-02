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
        if profileImage == nil {
            feedbackMessage = "Please select a profile image."
            return
        }
        do {
            loginRegisterPressed = true
            let result = try await FirebaseManager.shared.auth
                .createUser(withEmail: email, password: password)
            print("Successfully created user: \(result.user.uid)")

            if profileImage == nil {
                await storeUserInformation(profileImageUrl: URL(string: "www.google.com")! )
                
                FirebaseManager.shared.loggedInUser = User(uid: result.user.uid, email: email, profileImageUrl: URL(string: "www.google.com")!, fcmToken: FirebaseManager.shared.fcmToken ?? "")
                loginRegisterPressed = false
            } else if let url = await storeProfileImage() {
                await storeUserInformation(profileImageUrl: url)
                
                FirebaseManager.shared.loggedInUser = User(uid: result.user.uid, email: email, profileImageUrl: url, fcmToken: FirebaseManager.shared.fcmToken ?? "")
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
            await FirebaseManager.getUserInformation()
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
                .reference(withPath: "\(uid)_\(abs(Date().hashValue))")
            
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
                        FirebaseConstants.profileImageUrl: profileImageUrl.absoluteString,
                        FirebaseConstants.fcmToken: FirebaseManager.shared.fcmToken ?? ""]
        do {
            try await FirebaseManager.shared.firestore
                .collection(FirebaseConstants.users)
                .document(uid)
                .setData(userData)
            print("successfully saved user data to firestore")
        } catch {
            print(error)
        }
    }
}
