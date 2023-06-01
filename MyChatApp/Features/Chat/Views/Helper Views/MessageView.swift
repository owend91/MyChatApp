//
//  MessageView.swift
//  MyChatApp
//
//  Created by David Owen on 6/1/23.
//

import SwiftUI

struct MessageView: View {

    let message: ChatMessage
    let userChattingWith: User

    var centerMessage = false

    var body: some View {
        HStack {
            if message.fromId == FirebaseManager.shared.loggedInUser?.uid && !centerMessage {
                Spacer()
            }
            
            Group {
                if let imageUrl = message.imageUrl {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 200)
                                .padding(.horizontal)
                                .padding(.vertical, -10)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .frame(width: 200, height: 200)
                                .padding(.horizontal)
                                .padding(.vertical, -10)
                            
                        case .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text(message.text)
                        .padding()

                }
            }
            .background { message.fromId == userChattingWith.uid ? Color.white : Color.blue }
            .foregroundColor(message.fromId == userChattingWith.uid ? Color.black : Color.white)
            .cornerRadius(10)
            .overlay(alignment: .bottomLeading , content: {
                if message.reaction != .none {
                    ZStack {
                        Circle()
                            .foregroundColor(.gray)
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundColor(Color(.white))
                        
                    }
                    .frame(width: 30, height: 30)
                    .offset(x: -12, y: 12)
                }
            })
                
            if message.fromId == userChattingWith.uid && !centerMessage{
                Spacer()
            }
            
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: ChatMessage.longSample, userChattingWith: User.sampleMessagingUser)
    }
}
