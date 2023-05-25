//
//  ChatView.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import SwiftUI

struct ChatView: View {
    let userChattingWith: User
    @State var chatText = ""
    var body: some View {
        VStack {
            chatMessages
            chatBottomBar
            
        }
        .navigationTitle(userChattingWith.email)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatView(userChattingWith: User.sampleMessagingUser)
        }
    }
}

extension ChatView {
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                descriptionPlaceholder
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                
            } label: {
                Text("Send")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var chatMessages: some View {
        ZStack {
            ColorConstants.background
            ScrollView {
                ForEach(ChatMessage.samples) { message in
                    MessageView(message: message, userChattingWith: userChattingWith)
                }
                HStack {
                    Spacer()
                }
            }
            .padding(.top, 1)
            
            
        }
    }
    
    private var descriptionPlaceholder: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct MessageView: View {
    let message: ChatMessage
    let userChattingWith: User
    var body: some View {
        HStack {
            if message.fromId == FirebaseManager.shared.loggedInUser?.uid {
                Spacer()
            }
            Text(message.text)
                .padding()
                .background { message.fromId == userChattingWith.uid ? Color.white : Color.blue }
                .foregroundColor(message.fromId == userChattingWith.uid ? Color.black : Color.white)
                .cornerRadius(10)
            if message.fromId == userChattingWith.uid {
                Spacer()
            }

        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
