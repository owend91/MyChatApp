//
//  ChatView.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import SwiftUI

struct ChatView: View {
    let userChattingWith: User
    var body: some View {
        Text("Chat View!")
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(userChattingWith: User(uid: "", email: "", profileImageUrl: URL(string: "")))
    }
}
