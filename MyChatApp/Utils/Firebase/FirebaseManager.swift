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
    @Published var loggedInUser: User?

    static let shared = FirebaseManager()
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
    }
    
    @MainActor
    static func getUserInformation() async {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        print("get user info uid: \(uid)")
        do {
            let snapshot = try await FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(uid).getDocument()
            print("user snapshot received")
            guard let data = snapshot.data() else {
                print("error with data")
                return
                
            }
            
            FirebaseManager.shared.loggedInUser = User(data: data)
            print("user fetched")
            
        } catch {
            print("Error fetching user info: \(error.localizedDescription)")
        }
    }
}
