//
//  MessageHomeView.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI

struct MessageHomeView: View {
    let loggedInUser: User
    @State private var showSettings = false
    @StateObject var vm = MessageHomeViewModel()
    @EnvironmentObject var routerManager: NavigationRouter
    var body: some View {
        ZStack {
            ColorConstants.background.ignoresSafeArea()
            VStack {
                headerBar
                
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
                    routerManager.reset()
                }
            }
        }
    }
}

struct MessageHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MessageHomeView(loggedInUser: User(uid: "KZxy244JOkZrObXFsruHAyCsdlw2", email: "user2@gmail.com", profileImageUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/mychatapp-fe585.appspot.com/o/KZxy244JOkZrObXFsruHAyCsdlw2?alt=media&token=b4f16880-b2b4-43bd-b38f-9d3b7b19e330")))
    }
}

extension MessageHomeView {
    var headerBar: some View {
        HStack(spacing: 10) {
            AsyncImage(url: loggedInUser.profileImageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay {
                        RoundedRectangle(cornerRadius: 80)
                            .stroke(Color(.label), lineWidth: 1)
                    }
                    .shadow(radius: 5)
            } placeholder: {
                ProgressView()
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
}
