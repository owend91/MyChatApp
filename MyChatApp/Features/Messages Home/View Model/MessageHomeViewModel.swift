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
    private var firestoreListener: ListenerRegistration?
    
    
    @MainActor
    init(){
        getAllRecentMessages()
    }
    
    func handleSignOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            userSignedOut = true
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func getAllRecentMessages() {
        guard let currentUser = FirebaseManager.shared.loggedInUser else { return }
        recentMessages.removeAll()
        
        
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
}
