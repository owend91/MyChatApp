//
//  LogInView.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI

struct LogInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var routerManager: NavigationRouter
    @State var showRegisterModal = false
    @StateObject var vm = LogInViewModel()
    var body: some View {
        ZStack {
            ColorConstants.background.ignoresSafeArea()
            VStack {
                EmailPasswordForm(email: $vm.email,
                                  password: $vm.password,
                                  buttonText: "Log In") {
                    vm.feedbackMessage = nil
                    Task {
                        await vm.loginAccount()
                        if let user = FirebaseManager.shared.loggedInUser {
                            routerManager.push(to: .messageHome(loggedInUser: user))
                        }
                    }
                }
                
                Button {
                    showRegisterModal.toggle()
                } label: {
                    Text("Register?")
                }
                .padding(.top)
                
                if let message = vm.feedbackMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal)
            
        }
        .fullScreenCover(isPresented: $showRegisterModal) {
            RegisterView(vm: vm)
        }
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
        .task {
            
            if let _ = FirebaseManager.shared.auth.currentUser {
                await FirebaseManager.getUserInformation()
                if let user = FirebaseManager.shared.loggedInUser {
                    routerManager.push(to: .messageHome(loggedInUser: user))
                }
            }
            vm.email = ""
            vm.password = ""
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
