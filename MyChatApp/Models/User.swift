//
//  User.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import Foundation

struct User: Identifiable, Equatable {
    var id: String { uid }
    let uid: String
    let email: String
    let profileImageUrl: URL?
    
    var userName: String {
        email.components(separatedBy: "@")[0]
    }
    
    init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = URL(string: data[FirebaseConstants.profileImageUrl] as? String ?? "")
    }
    init(uid: String, email: String, profileImageUrl: URL?) {
        self.uid = uid
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
}
