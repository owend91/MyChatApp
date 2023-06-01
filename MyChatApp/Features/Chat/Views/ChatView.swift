//
//  ChatView.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var vm: ChatViewModel
    @State var initialMessageLoad = true
    @State var shouldShowImagePicker = false
    @State var selectedMessage: ChatMessage?

    
    var body: some View {
        ZStack {
            VStack {
                chatMessages
                if selectedMessage != nil {
                    Color(.darkGray)
                        .opacity(0.2)
                }
                chatBottomBar
            }
            .blur(radius: selectedMessage == nil ? 0 : 75)
            if let selectedMessage {
                HStack {
                    Spacer()
                    MessageView(message: selectedMessage, userChattingWith: vm.chattingWithUser, centerMessage: true)
                        .overlay(alignment: .top , content: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 60)
                                    .foregroundColor(.gray)
                                    .frame(width: 200, height: 40)
                                HStack {
                                    Button {
                                        Task {
                                            await vm.updateMessageReaction(reaction: .like, message: selectedMessage)
                                                self.selectedMessage = nil
                                        }
                                    } label: {
                                        Image(systemName: "hand.thumbsup.fill")
                                            .foregroundColor(Color(.white))
                                    }
                                }
                                
                            }
                            .frame(width: 30, height: 30)
                            .offset(x: 0, y: -35)
                            
                            
                        })
                    Spacer()
                }
                
            }
            
        }
        .onTapGesture {
            selectedMessage = nil
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
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
            }
            .fullScreenCover(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $vm.pictureForMessage)
            }
            
            

            ZStack {
                if let image = vm.pictureForMessage {
                    HStack {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                        Spacer()
                    }
                    .onTapGesture {
                        vm.pictureForMessage = nil
                    }
                } else {
                    descriptionPlaceholder
                    TextEditor(text: $vm.text)
                        .opacity(vm.text.isEmpty ? 0.5 : 1)
                }
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
            .disabled(vm.text.isEmpty && vm.pictureForMessage == nil)
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
                            .onLongPressGesture {
                                withAnimation {
                                    selectedMessage = message
                                }
                            }
                            
                    }
                    HStack {
                        Spacer()
                    }
                    .frame(width: 1, height: 1)
                    .id("BOTTOM")
                    .onReceive(vm.$chatCount) { _ in
                        if initialMessageLoad {
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


