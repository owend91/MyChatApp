//
//  EmailPasswordForm.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI

struct EmailPasswordForm: View {
    @Binding var email: String
    @Binding var password: String
    var buttonText = ""
    let buttonAction: () -> ()

    var body: some View {
        VStack {
            Group {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            
            Button {
                buttonAction()
            } label: {
                HStack {
                    Spacer()
                    Text(buttonText)
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                .padding(8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
}

struct EmailPasswordForm_Previews: PreviewProvider {
    static var previews: some View {
        EmailPasswordForm(email: .constant(""), password: .constant("")) {}
    }
}
