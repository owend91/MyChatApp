//
//  ChatViewModel.swift
//  MyChatApp
//
//  Created by David Owen on 5/26/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import UIKit

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
        print("init called")
    }
    
    deinit {
        print("deinit called")
        firestoreListener?.remove()
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
        let chatPartnerMessage = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.chatMessages)
            .document(toId)
            .collection(fromId)
            .document()
        let imageUrl = await storeMessageImage()

        
        let currentUserMessageData = [FirebaseConstants.fromId: fromId,
                           FirebaseConstants.toId: toId,
                           FirebaseConstants.text: text,
                           FirebaseConstants.timestamp: Timestamp(),
                           FirebaseConstants.messageImage: imageUrl?.absoluteString as? String ?? "",
                           FirebaseConstants.reciprocalMessageId: chatPartnerMessage.documentID] as [String: Any]
        
        let chatPartnerMessageData = [FirebaseConstants.fromId: fromId,
                           FirebaseConstants.toId: toId,
                           FirebaseConstants.text: text,
                           FirebaseConstants.timestamp: Timestamp(),
                           FirebaseConstants.messageImage: imageUrl?.absoluteString as? String ?? "",
                           FirebaseConstants.reciprocalMessageId: currentUserMessage.documentID] as [String: Any]
        
        do {
            backupText = text
            text = ""
            pictureForMessage = nil
            try await currentUserMessage.setData(currentUserMessageData)
            try await chatPartnerMessage.setData(chatPartnerMessageData)
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
        
        let chattingWithUserDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessage)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(fromId)
        
        
        let dataForCurrentUser = [FirebaseConstants.fromId: fromId,
                                  FirebaseConstants.toId: toId,
                                  FirebaseConstants.email: chattingWithUser.email,
                                  FirebaseConstants.text: backupText,
                                  FirebaseConstants.profileImageUrl: chattingWithUser.profileImageUrl?.absoluteString as? String ?? "",
                                  FirebaseConstants.timestamp: Timestamp(),
                                  FirebaseConstants.messageImage: imageUrl?.absoluteString as? String ?? ""] as [String: Any]
        
        
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
            await downloadImage(chattingWithUid: chattingWithUser.uid, url: chattingWithUser.profileImageUrl)
            
        } catch {
            print("Error saving recent message: \(error)")
        }
        
    }
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.loggedInUser?.uid else { return }
        let toId = chattingWithUser.uid
        chatMessages.removeAll()
//        firestoreListener?.remove()
        
        firestoreListener = FirebaseManager
            .shared
            .firestore
            .collection(FirebaseConstants.chatMessages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error adding chat log listener: \(error)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ documentChange in
                    if documentChange.type == .added {
                        let data = documentChange.document.data()
                        let documentId = documentChange.document.documentID
                        
                        let message = ChatMessage(documentId: documentId, data: data)
                        self.chatMessages.append(message)
                    } else if documentChange.type == .modified {
                        let data = documentChange.document.data()
                        let documentId = documentChange.document.documentID
                        let message = ChatMessage(documentId: documentId, data: data)
                        
                        if let index = self.chatMessages.firstIndex(where: {$0.documentId == documentId}) {
                            self.chatMessages[index] = message
                        }
                        
                    }
                })
                
                DispatchQueue.main.async {
                    self.chatCount += 1
                    print("snapshot listener chatcount: \(self.chatCount)")
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
        
        let serverKey = FirebaseKeys.fcmKey
        
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
    
    func updateMessageReaction(reaction: ChatReaction, message: ChatMessage) async {
        guard let loggedInUser = FirebaseManager.shared.loggedInUser else { return }
        var currentUserMessage: DocumentReference? = nil
        var chatPartnerMessage: DocumentReference? = nil
        if message.fromId == loggedInUser.uid {
            currentUserMessage = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chatMessages)
                .document(message.fromId)
                .collection(message.toId)
                .document(message.documentId)
            chatPartnerMessage = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chatMessages)
                .document(message.toId)
                .collection(message.fromId)
                .document(message.reciprocalMessageId)
        } else {
            currentUserMessage = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chatMessages)
                .document(message.toId)
                .collection(message.fromId)
                .document(message.documentId)
            chatPartnerMessage = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.chatMessages)
                .document(message.fromId)
                .collection(message.toId)
                .document(message.reciprocalMessageId)
        }
        
        do {
            if let currentUserMessage = currentUserMessage, let chatPartnerMessage = chatPartnerMessage {
                let reactionVal = message.reaction == reaction ? ChatReaction.none.rawValue : reaction.rawValue
                try await currentUserMessage.setData([FirebaseConstants.chatReaction : reactionVal], mergeFields: [FirebaseConstants.chatReaction])
                try await chatPartnerMessage.setData([FirebaseConstants.chatReaction : reactionVal], mergeFields: [FirebaseConstants.chatReaction])
            }
        } catch {
            print("Error reacting to a message: \(error)")
        }
    }
    
    func downloadImage(chattingWithUid: String, url: URL?) async {
        if let url = url {
            let urlString = url.absoluteString
            let tokens = urlString.components(separatedBy: "o/")
            let usefulToken = tokens[1]
            let imageName = usefulToken.components(separatedBy: "?")[0]
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let localImageUrl = documents.appendingPathComponent("\(imageName).png")
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let pathUrl = NSURL(fileURLWithPath: path)
            let fileManager = FileManager.default
            if let pathComponent = pathUrl.appendingPathComponent("\(imageName).png") {
                let filePath = pathComponent.path
                if fileManager.fileExists(atPath: filePath){
                    print("Image already exists")
                    return
                }
            }
            
            do {
                let items = try fileManager.contentsOfDirectory(atPath: path)
                
                for item in items {
                    if item.starts(with: chattingWithUid) {
                        let imageToDelete = documents.appendingPathComponent(item)
                        try fileManager.removeItem(at: imageToDelete)
                        print("old image deleted")
                        break
                    }
                }
                
                let (data, _) = try await URLSession.shared.data(from: url)
                
                try data.write(to: localImageUrl)
                print("Image saved to: \(localImageUrl)")
                
            } catch {
                print("Error saving image")
            }
        }
    }
}
