//
//  MessageHomeViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import Foundation
import Firebase

class MessageHomeViewModel: ObservableObject {
    @Published var userSignedOut = false
    @Published var recentMessages: [RecentMessage] = []
    @Published var newProfileImage: UIImage?
    var firestoreListener: ListenerRegistration?
    
    
    @MainActor
    init(){
        getAllRecentMessages()
    }
    
    func handleSignOut() {
        do {
            firestoreListener?.remove()
            firestoreListener = nil
            try FirebaseManager.shared.auth.signOut()
            FirebaseManager.shared.loggedInUser = nil
            userSignedOut = true
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func getAllRecentMessages() {
        guard let currentUser = FirebaseManager.shared.loggedInUser else { return }
        recentMessages.removeAll()
        firestoreListener?.remove()
        
        
        firestoreListener = FirebaseManager
            .shared
            .firestore
            .collection(FirebaseConstants.recentMessage)
            .document(currentUser.uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error adding recent messages listened: \(error)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ documentChange in
                    let data = documentChange.document.data()
                    let documentId = documentChange.document.documentID
                    self.recentMessages.removeAll { $0.documentId == documentChange.document.documentID }
                    let recentMessage = RecentMessage(documentId: documentId, data: data)
                    self.recentMessages.append(recentMessage)
                    
                })
            }
    }
    
    @MainActor
    func updateAvatar() async -> URL? {
        await deleteOldProfileImage()
        if let url = await storeProfileImage() {
            await updateProfileInformation(profileImageUrl: url)
            return url
        }
        return nil
    }
    
    @MainActor
    func deleteOldProfileImage() async {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        do {
            let ref = FirebaseManager.shared.storage
                .reference(withPath: "\(uid)_\(abs(Date().hashValue))")
            try await ref.delete()
            
        } catch {
            print("Failed to delete profile image from storage: \(error)")
            return
        }
    }
    
    @MainActor
    func storeProfileImage() async -> URL? {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return nil }
        
        do {
            let ref = FirebaseManager.shared.storage
                .reference(withPath:  "\(uid)_\(abs(Date().hashValue))")
            
            guard let imageData = self.newProfileImage?.jpegData(compressionQuality: 0.2) else { return nil }
            
            let _ = try await ref.putDataAsync(imageData)
            return try await ref.downloadURL()
            
        } catch {
            print("Failed to push profile image to storage: \(error)")
            return nil
        }
    }
    
    @MainActor
    func updateProfileInformation(profileImageUrl: URL) async {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.profileImageUrl: profileImageUrl.absoluteString]
        do {
            try await FirebaseManager.shared.firestore
                .collection(FirebaseConstants.users)
                .document(uid)
                .setData(userData, mergeFields: [FirebaseConstants.profileImageUrl])
            print("successfully updated user data in firestore")
        } catch {
            print(error)
        }
    }
}
