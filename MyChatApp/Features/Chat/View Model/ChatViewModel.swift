//
//  ChatViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/26/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var text = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var chatCount = 0
    @Published var pictureForMessage: UIImage?
    
    let chattingWithUser: User
    var firestoreListener: ListenerRegistration?
    var backupText = ""
    
    
    init(chattingWithUser: User) {
        self.chattingWithUser = chattingWithUser
        fetchMessages()
    }
    
    @MainActor
    func sendMessage() async {
        guard let loggedInUser = FirebaseManager.shared.loggedInUser else { return }
        let fromId = loggedInUser.uid
        let toId = chattingWithUser.uid
        let currentUserMessage = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chatMessages)
            .document(fromId)
            .collection(toId)
            .document()
        let imageUrl = await storeMessageImage()
        
        let messageData = [FirebaseConstants.fromId: fromId,
                           FirebaseConstants.toId: toId,
                           FirebaseConstants.text: text,
                           FirebaseConstants.timestamp: Timestamp(),
                           FirebaseConstants.messageImage: imageUrl?.absoluteString as? String ?? ""] as [String: Any]
        
        let chatPartnerMessage = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chatMessages)
            .document(toId)
            .collection(fromId)
            .document()
        
        
        do {
            backupText = text
            text = ""
            pictureForMessage = nil
            try await currentUserMessage.setData(messageData)
            try await chatPartnerMessage.setData(messageData)
            await saveRecentMessage(imageUrl: imageUrl)
            await sendPushNotification(fromUser: loggedInUser.userName, message: backupText, deviceToken: chattingWithUser.fcmToken)
            backupText = ""
            
        } catch {
            print("Error saving message: \(error)")
        }
    }
    
    func saveRecentMessage(imageUrl: URL?) async {
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
                                  FirebaseConstants.timestamp: Timestamp(),
                                  FirebaseConstants.messageImage: imageUrl?.absoluteString as? String ?? ""] as [String: Any]
        
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
                                       FirebaseConstants.timestamp: Timestamp(),
                                       FirebaseConstants.messageImage: imageUrl?.absoluteString as? String ?? ""] as [String: Any]
        
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
    
    @MainActor
    func storeMessageImage() async -> URL? {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return nil }
        guard let image = pictureForMessage else { return nil }
        
        do {
            let ref = FirebaseManager.shared.storage
                .reference(withPath: "\(uid)_\(image.hash)")
            
            guard let imageData = image.jpegData(compressionQuality: 0.2) else { return nil }
            
            let _ = try await ref.putDataAsync(imageData)
            return try await ref.downloadURL()
            
        } catch {
            print("Failed to push message image to storage: \(error)")
            return nil
        }
    }
    
    func sendPushNotification(fromUser: String, message: String, deviceToken: String) async {
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            return
        }
        let json: [String: Any] = [
            "to": deviceToken,
            "notification" : [
                "title": fromUser,
                "body": message.isEmpty ? "Picture Received" : message
            ]
//            Dont pass empty or remove the block
//            ,"data": [
//                //data to be sent...
//            ]

        ]
        
        let serverKey = ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")

        let session = URLSession(configuration: .default)
        do {
            let (_, _ ) = try await session.data(for: request)
        } catch {
            print("Error sending push notification: \(error)")
        }
    }
}
