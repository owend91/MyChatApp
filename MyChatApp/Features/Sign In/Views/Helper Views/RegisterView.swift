//
//  RegisterView.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var routerManager: NavigationRouter
    @ObservedObject var vm: LogInViewModel
    var body: some View {
        
        NavigationStack {
            ZStack {
                ColorConstants.background.ignoresSafeArea()
                VStack {
                    EmailPasswordForm(email: $vm.email,
                                      password: $vm.password,
                                      buttonText: "Register") {
                        vm.feedbackMessage = nil
                        Task {
                            await vm.registerNewAccount()
                            if let uid = FirebaseManager.shared.loggedInUid {
                                dismiss()
                                routerManager.push(to: .messageHome(uid: uid))
                            }
                        }
                        
                    }
                    if let message = vm.feedbackMessage {
                        Text(message)
                            .foregroundColor(.red)
                    }
                    
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal)
                
            }
            .navigationTitle("Register")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(vm: LogInViewModel())
    }
}
