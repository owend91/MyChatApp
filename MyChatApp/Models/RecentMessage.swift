//
//  RecentMessage.swift
//  MyChatApp
//
//  Created by David Owen on 5/26/23.
//

import Foundation
import Firebase

struct RecentMessage: Identifiable, Hashable {
    var id: String { documentId }
    let documentId: String
    let text, fromId, toId: String
    let email, profileImageUrl: String
    let timestamp: Timestamp
    let imageUrl: URL?
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        var tempText = data[FirebaseConstants.text] as? String ?? ""
        self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp ?? Timestamp(date: Date())
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        let imgUrl = data[FirebaseConstants.messageImage] as? String ?? ""
        if imgUrl.isEmpty {
            imageUrl = nil
        } else {
            imageUrl = URL(string: imgUrl)
            if let currUserUid = FirebaseManager.shared.loggedInUser?.uid {
                if currUserUid == fromId {
                    tempText = "Image Sent"
                } else {
                    tempText = "Image Received"
                }
            }
        }
        self.text = tempText
    }
    
    var username: String {
        let tokens = email.components(separatedBy: "@")
        return tokens[0]
    }
    
    var timeSinceMessage: String {
        let date = timestamp.dateValue()
        let now = Date()
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second, .day, .year, .month], from: date, to: now)
        let years = diffComponents.year
        let months = diffComponents.month
        let days = diffComponents.day
        let hours = diffComponents.hour
        let minutes = diffComponents.minute

        if let years, years > 0  {
            return "\(years)y"
        } else if let months, months > 0 {
            return "\(months)mo"
        } else if let days, days > 0 {
            return "\(days)d"
        } else if let hours, hours > 0 {
            return "\(hours)h"
        } else if let minutes, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "<1m"
        }
        
    }
}
