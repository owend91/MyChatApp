//
//  MessageHomeView.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI

struct MessageHomeView: View {
    let uid: String
    var body: some View {
        Text("\(uid) logged in")
            .navigationBarBackButtonHidden()
    }
}

struct MessageHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MessageHomeView(uid: "asd324rafdrest")
    }
}
