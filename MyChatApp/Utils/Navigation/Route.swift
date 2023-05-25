//
//  Route.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import Foundation
import SwiftUI

enum Route {
    
    
    case messageHome(uid: String)
}

extension Route: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch(lhs, rhs) {
        case (.messageHome, .messageHome):
            return true
//        default:
//            return false
        }
        
    }
}

extension Route: View {
    var body: some View {
        switch self {

        case .messageHome(let uid):
            MessageHomeView(uid: uid)
        }
    }
}

