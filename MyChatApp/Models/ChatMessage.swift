//
//  ChatMessage.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import Foundation

enum ChatReaction: String, CaseIterable {
    case none
    case like
    case dislike
    case love
    case enthuse
    case question
    
    func getSfSymbol() -> String {
        switch self {
            
        case .none:
            return ""
        case .like:
            return "hand.thumbsup.fill"
        case .dislike:
            return "hand.thumbsdown.fill"
        case .love:
            return "heart.fill"
        case .enthuse:
            return "exclamationmark.circle.fill"
        case .question:
            return "questionmark.circle.fill"
        }
    }
}

struct ChatMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let fromId: String
    let toId: String
    let text: String
    let reciprocalMessageId: String
    let imageUrl: URL?
    var reaction: ChatReaction = .none
    
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
        reciprocalMessageId = data[FirebaseConstants.reciprocalMessageId] as? String ?? ""
        let imgUrl = data[FirebaseConstants.messageImage] as? String ?? ""
        if imgUrl.isEmpty {
            imageUrl = nil
        } else {
            imageUrl = URL(string: imgUrl)
        }
        reaction = ChatReaction(rawValue: (data[FirebaseConstants.chatReaction] as? String) ?? "none") ?? .none
    }
    init(documentId: String, fromId: String, toId: String, text: String, reaction: ChatReaction, reciprocalMessageId: String) {
        self.documentId = documentId
        self.fromId = fromId
        self.toId = toId
        self.text = text
        imageUrl = nil
        self.reaction = reaction
        self.reciprocalMessageId = reciprocalMessageId
    }
}

extension ChatMessage {
    static let samples = [
        ChatMessage(documentId: "1", fromId: User.sampleCurrentUser.uid, toId: User.sampleMessagingUser.uid, text: "Hello", reaction: .none, reciprocalMessageId: "1"),
        ChatMessage(documentId: "2", fromId: User.sampleMessagingUser.uid, toId: User.sampleCurrentUser.uid, text: "Hello", reaction: .none, reciprocalMessageId: "2"),
        ChatMessage(documentId: "3", fromId: User.sampleCurrentUser.uid, toId: User.sampleMessagingUser.uid, text: "How are you?", reaction: .none, reciprocalMessageId: "3"),
        ChatMessage(documentId: "4", fromId: User.sampleMessagingUser.uid, toId: User.sampleCurrentUser.uid, text: "I'm fine.  And you?", reaction: .none, reciprocalMessageId: "4"),
        ChatMessage(documentId: "3", fromId: User.sampleCurrentUser.uid, toId: User.sampleMessagingUser.uid, text: "Great!", reaction: .none, reciprocalMessageId: "5")
        ]
    static let longSample = ChatMessage(documentId: "1", fromId: User.sampleCurrentUser.uid, toId: User.sampleMessagingUser.uid, text: "This is a really really really really really really really really really long message", reaction: .none, reciprocalMessageId: "1")

}
