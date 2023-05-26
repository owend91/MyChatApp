//
//  ChatMessage.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import Foundation

struct ChatMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let fromId: String
    let toId: String
    let text: String
    let imageUrl: URL?
    
    var isSentByCurrUser: Bool {
        guard let currUserId = FirebaseManager.shared.auth.currentUser?.uid else { return false }
        if fromId == currUserId {
            return true
        } else {
            return false
        }
    }
    
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        fromId = data[FirebaseConstants.fromId] as? String ?? ""
        toId = data[FirebaseConstants.toId] as? String ?? ""
        text = data[FirebaseConstants.text] as? String ?? ""
        let imgUrl = data[FirebaseConstants.messageImage] as? String ?? ""
        if imgUrl.isEmpty {
            imageUrl = nil
        } else {
            imageUrl = URL(string: imgUrl)
        }
    }
    init(documentId: String, fromId: String, toId: String, text: String) {
        self.documentId = documentId
        self.fromId = fromId
        self.toId = toId
        self.text = text
        imageUrl = nil
    }
}

extension ChatMessage {
    static let samples = [
        ChatMessage(documentId: "1", fromId: User.sampleCurrentUser.uid, toId: User.sampleMessagingUser.uid, text: "Hello"),
        ChatMessage(documentId: "2", fromId: User.sampleMessagingUser.uid, toId: User.sampleCurrentUser.uid, text: "Hello"),
        ChatMessage(documentId: "3", fromId: User.sampleCurrentUser.uid, toId: User.sampleMessagingUser.uid, text: "How are you?"),
        ChatMessage(documentId: "4", fromId: User.sampleMessagingUser.uid, toId: User.sampleCurrentUser.uid, text: "I'm fine.  And you?"),
        ChatMessage(documentId: "3", fromId: User.sampleCurrentUser.uid, toId: User.sampleMessagingUser.uid, text: "Great!")
        ]
}
