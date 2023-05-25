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
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                ColorConstants.background.ignoresSafeArea()
                VStack {
                    Button {
                        shouldShowImagePicker.toggle()
                    } label: {
                        if let _ = vm.profileImage {
                            selectedImageView
                            
                        } else {
                            nonSelectedImageView
                        }
                    }
                    .fullScreenCover(isPresented: $shouldShowImagePicker) {
                        ImagePicker(image: $vm.profileImage)
                    }
                    
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
                    if vm.loginRegisterPressed {
                        ProgressView()
                    } else if let message = vm.feedbackMessage {
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

extension RegisterView {
    var selectedImageView: some View {
        //profile image will have been nil checked before this, safe to unwrap!
        Image(uiImage: vm.profileImage!)
            .resizable()
            .scaledToFill()
            .clipped()
            .frame(width: 110, height: 110)
            .clipShape(Circle())
            .overlay {
                RoundedRectangle(cornerRadius: 80)
                    .stroke(Color(.label), lineWidth: 3)
            }
            .padding()
    }
    
    var nonSelectedImageView: some View {
        Image(systemName: "person.fill")

            .foregroundColor(Color(.label))
            .font(.system(size: 80))
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color(.label), lineWidth: 3)
            }
            .padding()
    }
}
