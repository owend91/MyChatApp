//
//  NewMessageViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import Foundation

class NewMessageViewModel: ObservableObject {
    let currentUser = FirebaseManager.shared.loggedInUser
    @Published var allUsers: [User] = []
    
    @MainActor
    func getAllUsers() async {
        
        do {
            let querySnapshot = try await FirebaseManager.shared.firestore
                .collection(FirebaseConstants.users)
                .getDocuments()
            
            querySnapshot.documents.forEach { document in
                allUsers.append(.init(data: document.data()))
            }
        } catch {
            print("Error getting all users: \(error)")
        }
       
    }
}
