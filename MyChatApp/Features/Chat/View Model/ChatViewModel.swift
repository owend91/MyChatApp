//
//  ChatViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/26/23.
//

import Foundation
import Firebase

class ChatViewModel: ObservableObject {
    @Published var text = ""
    var backupText = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var chatCount = 0
    var firestoreListener: ListenerRegistration?
    let chattingWithUser: User
    
    init(chattingWithUser: User) {
        self.chattingWithUser = chattingWithUser
        fetchMessages()
    }
    
    @MainActor
    func sendMessage() async {
        guard let fromId = FirebaseManager.shared.loggedInUser?.uid else { return }
        let toId = chattingWithUser.uid
        let currentUserMessage = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chatMessages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId,
                           FirebaseConstants.toId: toId,
                           FirebaseConstants.text: text,
                           FirebaseConstants.timestamp: Timestamp()] as [String: Any]
        
        let chatPartnerMessage = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chatMessages)
            .document(toId)
            .collection(fromId)
            .document()
        
        
        do {
            backupText = text
            text = ""
            try await currentUserMessage.setData(messageData)
            try await chatPartnerMessage.setData(messageData)
            await saveRecentMessage()
            backupText = ""
            
        } catch {
            print("Error saving message: \(error)")
        }
    }
    
    func saveRecentMessage() async {
        guard let fromId = FirebaseManager.shared.loggedInUser?.uid else { return }
        let toId = chattingWithUser.uid
        
        let currentUserDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessage)
            .document(fromId)
            .collection(FirebaseConstants.messages)
            .document(toId)
        

        let dataForCurrentUser = [FirebaseConstants.fromId: fromId,
                    FirebaseConstants.toId: toId,
                    FirebaseConstants.email: chattingWithUser.email,
                    FirebaseConstants.text: backupText,
                                  FirebaseConstants.profileImageUrl: chattingWithUser.profileImageUrl?.absoluteString as? String ?? "",
                                  FirebaseConstants.timestamp: Timestamp() ] as [String: Any]
        
        let chattingWithUserDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessage)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(fromId)
        

        let dataForChattingWithUser = [FirebaseConstants.fromId: fromId,
                    FirebaseConstants.toId: toId,
                    FirebaseConstants.email: FirebaseManager.shared.loggedInUser?.email as? String ?? "",
                    FirebaseConstants.text: backupText,
                    FirebaseConstants.profileImageUrl: FirebaseManager.shared.loggedInUser?.profileImageUrl?.absoluteString as? String ?? "",
                                  FirebaseConstants.timestamp: Timestamp() ] as [String: Any]
        
        do {
            try await currentUserDocument.setData(dataForCurrentUser)
            try await chattingWithUserDocument.setData(dataForChattingWithUser)
        } catch {
            print("Error saving recent message: \(error)")
        }
        
    }
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.loggedInUser?.uid else { return }
        let toId = chattingWithUser.uid
        chatMessages.removeAll()

        firestoreListener = FirebaseManager
            .shared
            .firestore
            .collection(FirebaseConstants.chatMessages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error adding chat log listened: \(error)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ documentChange in
                    print("document change")
                    if documentChange.type == .added {
                        let data = documentChange.document.data()
                        let documentId = documentChange.document.documentID
                        
                        let message = ChatMessage(documentId: documentId, data: data)
                        self.chatMessages.append(message)
                    }
                })
                
                DispatchQueue.main.async{
                    self.chatCount += 1
                    print("incremented counter: \(self.chatCount)")
                }
            }
    }
    
    
}
