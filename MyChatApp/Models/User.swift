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
    var fcmToken: String
    
    var userName: String {
        email.components(separatedBy: "@")[0]
    }
    
    init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = URL(string: data[FirebaseConstants.profileImageUrl] as? String ?? "")
        self.fcmToken = data[FirebaseConstants.fcmToken] as? String ?? ""
    }
    
    init(uid: String, email: String, profileImageUrl: URL?, fcmToken: String) {
        self.uid = uid
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.fcmToken = fcmToken
    }
    
    init(recentMessage: RecentMessage) async {
        guard let currentUser = FirebaseManager.shared.loggedInUser else {
            self.uid = ""
            self.email = ""
            self.profileImageUrl = nil
            self.fcmToken = ""
            return
        }
        self.uid = currentUser.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
        self.email = recentMessage.email
        self.profileImageUrl = URL(string: recentMessage.profileImageUrl)
        self.fcmToken = await FirebaseManager.getUsersFcmToken(uid: self.uid)
    }
}

extension User {
    static var sampleCurrentUser = User(uid: "KZxy244JOkZrObXFsruHAyCsdlw2", email: "user2@gmail.com", profileImageUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/mychatapp-fe585.appspot.com/o/KZxy244JOkZrObXFsruHAyCsdlw2?alt=media&token=b4f16880-b2b4-43bd-b38f-9d3b7b19e330"), fcmToken: "")
    static var sampleMessagingUser = User(uid: "XLqLLCVOcmQ1qFhkT0k5ZzeEuKH3", email: "user3@gmail.com", profileImageUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/mychatapp-fe585.appspot.com/o/XLqLLCVOcmQ1qFhkT0k5ZzeEuKH3?alt=media&token=1eb8c20a-be72-4998-b9a9-3f796b7f0c6b"), fcmToken: "")
}
