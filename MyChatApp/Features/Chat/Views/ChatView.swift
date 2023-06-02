//
//  ChatView.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var routerManager: NavigationRouter
    @ObservedObject var vm: ChatViewModel
    @State var shouldShowImagePicker = false
    @State var selectedMessage: ChatMessage?
    @State var textViewTapped = false
    let haptics = UIImpactFeedbackGenerator(style: .medium)

    
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
            .onTapGesture {
                selectedMessage = nil
            }
            if let selectedMessage {
                HStack {
                    Spacer()
                    MessageView(message: selectedMessage, userChattingWith: vm.chattingWithUser, centerMessage: true)
                        .overlay(alignment: .top , content: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 60)
                                    .foregroundColor(.gray)
                                    .frame(width: 200, height: 40)
                                HStack(spacing: 15) {
                                    ForEach(ChatReaction.allCases, id: \.self) { reaction in
                                        if reaction != .none {
                                            Button {
                                                Task {
                                                    await vm.updateMessageReaction(reaction: reaction, message: selectedMessage)
                                                    self.selectedMessage = nil
                                                }
                                            } label: {
                                                Image(systemName: reaction.getSfSymbol())
                                                    .foregroundColor(Color(.white))
                                            }
                                        }
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
        .onDisappear {
            vm.firestoreListener?.remove()
            vm.firestoreListener = nil
        }
        .onAppear{
            print("route count: \(routerManager.routes.count)")
            print("routes: \(routerManager.routes)")
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
                        .onTapGesture {
                            textViewTapped.toggle()
                        }
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
                                if !message.isSentByCurrUser {
                                    withAnimation {
                                        haptics.impactOccurred()
                                        selectedMessage = message
                                    }
                                }
                            }
                    }
                    HStack {
                        Spacer()
                    }
                    .frame(width: 1, height: 1)
                    .id("BOTTOM")
                    .onReceive(vm.$chatCount) { _ in
                        print("On receive count: \(vm.chatCount)")
                        if vm.chatCount < 1 {
                            scrollViewProxy.scrollTo("BOTTOM")
                        } else {
                            DispatchQueue.main.async{
                                withAnimation(.easeOut(duration: 0.5)) {
                                    scrollViewProxy.scrollTo("BOTTOM")
                                }
                            }
                        }
                    }
                    .onChange(of: textViewTapped, perform: { _ in
                        print("textViewTapped changed")
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo("BOTTOM")
                            }
                        }
                    })
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


