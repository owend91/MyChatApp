//
//  Route.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import Foundation
import SwiftUI

enum Route {
    case messageHome(loggedInUser: User)
    case chatView(vm: ChatViewModel)
    case login
}

extension Route: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch(lhs, rhs) {
        case (.messageHome(let lhsItem), .messageHome(let rhsItem)):
            return lhsItem.uid == rhsItem.uid
        case (.chatView(let lhsItem), .chatView(let rhsItem)):
            return lhsItem.chattingWithUser.uid == rhsItem.chattingWithUser.uid
        case (.login, .login):
            return true
        default:
            return false
        }
    }
}

extension Route: View {
    var body: some View {
        switch self {

        case .messageHome(let loggedInUser):
            MessageHomeView(loggedInUser: loggedInUser)
        case .chatView(let vm):
            ChatView(vm: vm)
        case .login:
            LogInView()
        }
    }
}

