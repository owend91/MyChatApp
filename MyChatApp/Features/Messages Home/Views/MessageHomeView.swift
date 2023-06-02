//
//  MessageHomeView.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI

struct MessageHomeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var routerManager: NavigationRouter
    @StateObject var vm = MessageHomeViewModel()
    @State private var showSettings = false
    @State private var showNewMessasgeScreen = false
    @State var selectedUser: User?
    @State private var showUpdateProfileImage = false
    @State private var shouldShowImagePicker = false

    @State var loggedInUser: User

    var body: some View {
        ZStack {
            ColorConstants.background.ignoresSafeArea()
            VStack {
                headerBar
                    .padding(.vertical)
                ScrollView {
                    ForEach(vm.recentMessages) { rm in
                        Button {
                            Task {
                                selectedUser = await User(recentMessage: rm)
                            }
                        } label: {
                            HStack {
                                UserAvatarCircleView(url: URL(string: rm.profileImageUrl), dimension: 50, showShadow: false)
                                    .padding(.top, 1)
                                VStack(alignment: .leading) {
                                    Text(rm.username)
                                        .foregroundColor(Color(.label))
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    Text(rm.text)
                                        .foregroundColor(Color(.darkGray))
                                        .font(.system(size: 12))
                                }
                                Spacer()
                                Text(rm.timeSinceMessage)
                                    .font(.system(size: 12, weight: .bold))

                                
                            }
                        }
                        
                    }
                }
                Button {
                    showNewMessasgeScreen.toggle()
                } label: {
                    Spacer()
                    Text("+ New Message")
                        .padding(.vertical)
                    Spacer()
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .shadow(radius: 5)
                
            }
            .padding(.horizontal)
            .confirmationDialog("Settings", isPresented: $showSettings, titleVisibility: .visible, actions: {
                Button("Log Out", role: .destructive) {
                    vm.handleSignOut()
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("What do you want to do")
            })
            .onChange(of: vm.userSignedOut) { _ in
                if vm.userSignedOut {
                    routerManager.resetToLogin()
                }
            }
            .onChange(of: selectedUser, perform: { _ in
                if let selectedUser {
                    print("User selected")
                    routerManager.push(to: .chatView(vm: ChatViewModel(chattingWithUser: selectedUser)))
                }
            })
            .fullScreenCover(isPresented: $showNewMessasgeScreen) {
                NavigationStack {
                    NewMessageView(selectedUser: $selectedUser)
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear{
                selectedUser = nil
            }
            
            
        }
    }
}

struct MessageHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MessageHomeView(loggedInUser: User(uid: "KZxy244JOkZrObXFsruHAyCsdlw2", email: "user2@gmail.com", profileImageUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/mychatapp-fe585.appspot.com/o/KZxy244JOkZrObXFsruHAyCsdlw2?alt=media&token=b4f16880-b2b4-43bd-b38f-9d3b7b19e330"), fcmToken: ""))
    }
}

extension MessageHomeView {
    
    var headerBar: some View {
        HStack(spacing: 10) {
            Button {
                showUpdateProfileImage.toggle()
            } label: {
                UserAvatarCircleView(url: loggedInUser.profileImageUrl, dimension: 64, showShadow: true)
            }
            .popover(isPresented: $showUpdateProfileImage) {
                NavigationStack {
                    VStack {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            if let newImage = vm.newProfileImage {
                                selectedImageView
                            } else {
                                UserAvatarCircleView(url: loggedInUser.profileImageUrl, dimension: 150, showShadow: false)
                            }
                        }
                        .fullScreenCover(isPresented: $shouldShowImagePicker) {
                            ImagePicker(image: $vm.newProfileImage)

                        }
                        
                        Button {
                            Task {
                                if let newUrl = await vm.updateAvatar() {
                                    vm.newProfileImage = nil
                                    loggedInUser.profileImageUrl = newUrl
                                }
                            }
                            showUpdateProfileImage = false
                        } label: {
                            Spacer()
                            Text("Update Avatar")
                                .padding(.vertical)
                            Spacer()
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .shadow(radius: 5)
                        .padding()
                        
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                vm.newProfileImage = nil
                                showUpdateProfileImage = false
                            } label: {
                                Text("Close")
                            }
                        }
                    }
                }
            }
            
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(loggedInUser.userName)")
                    .font(.system(size: 24, weight: .bold))
                HStack(spacing: 3) {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 12, height: 12)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gear")
                    .foregroundColor(Color(.label))
                    .font(.system(size: 34, weight: .bold))
            }
            
        }
    }
    
    var selectedImageView: some View {
        Image(uiImage: vm.newProfileImage!)
            .resizable()
            .scaledToFill()
            .clipped()
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay {
                RoundedRectangle(cornerRadius: 80)
                    .stroke(Color(.label), lineWidth: 1)
            }
            .padding()
    }
}
