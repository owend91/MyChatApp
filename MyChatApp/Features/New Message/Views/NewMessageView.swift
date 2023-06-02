//
//  NewMessageView.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import SwiftUI

struct NewMessageView: View {
    @EnvironmentObject var routerManager: NavigationRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = NewMessageViewModel()
    @Binding var selectedUser: User?
    var body: some View {
        VStack {
            ScrollView {
                ForEach(vm.allUsers) { user in
                    Button {
                        selectedUser = user
                        dismiss()
                    } label: {
                        HStack(spacing: 15) {
                            LocalOrRemoteAvatarCircleView(image: user.localProfileImage, imageUrl: user.profileImageUrl?.absoluteString ?? "", dimension: 50, showShadow: true)

                            Text("\(user.email)")
                                .foregroundColor(Color(.label))
                            Spacer()

                        }
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("New Message")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .onAppear {
            Task {
                await vm.getAllUsers()
            }
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewMessageView(selectedUser: .constant(nil))
        }
    }
}
