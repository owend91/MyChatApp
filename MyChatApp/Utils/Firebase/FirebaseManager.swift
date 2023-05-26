//
//  FirebaseManager.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    @Published var loggedInUid: String?
    @Published var loggedInUser: User?
    
//    var currentUser: ChatUser?
    
    init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
    }
    
    @MainActor
    static func getUserInformation() async {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        do {
            let snapshot = try await FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(uid).getDocument()
            guard let data = snapshot.data() else { return }
            
            FirebaseManager.shared.loggedInUser = User(data: data)
            
        } catch {
            print("Error fetching user info: \(error.localizedDescription)")
        }
    }
}
