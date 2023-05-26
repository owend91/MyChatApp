//
//  ChatView.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import SwiftUI

struct ChatView: View {
//    let userChattingWith: User
    @ObservedObject var vm: ChatViewModel
    @State var initialMessageLoad = true
    var body: some View {
        VStack {
            chatMessages
            chatBottomBar
            
        }
        .onDisappear {
            vm.firestoreListener?.remove()
        }
        .navigationTitle(vm.chattingWithUser.email)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatView(vm: ChatViewModel(chattingWithUser: User.sampleMessagingUser))
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
                TextEditor(text: $vm.text)
                    .opacity(vm.text.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                Task {
                    await vm.sendMessage()
                }
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
                ScrollViewReader { scrollViewProxy in
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message, userChattingWith: vm.chattingWithUser)
                    }
                    HStack {
                        Spacer()
                    }
                    .frame(width: 1, height: 1)
                    .id("BOTTOM")
                    .onReceive(vm.$chatCount) { _ in
                        if initialMessageLoad {
//                            print("INitial load")
//                            withAnimation(.) {
//                                scrollViewProxy.scrollTo("BOTTOM")
//
//                            }
                            initialMessageLoad = false
                        } else {
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo("BOTTOM")
                            }
                        }
                    }
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
