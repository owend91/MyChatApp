//
//  UserAvatarCircleView.swift
//  MyChatApp
//
//  Created by David Owen on 5/25/23.
//

import SwiftUI

struct UserAvatarCircleView: View {
    let url: URL?
    let dimension: CGFloat
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: dimension, height: dimension)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: dimension, height: dimension)
                    .clipShape(Circle())
                    .overlay {
                        RoundedRectangle(cornerRadius: dimension)
                            .stroke(Color(.label), lineWidth: 1)
                    }
                    .shadow(radius: 5)
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                EmptyView()
            }
           
        }
    }
}

struct UserAvatarCircleView_Previews: PreviewProvider {
    static var previews: some View {
        UserAvatarCircleView(url: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/mychatapp-fe585.appspot.com/o/KZxy244JOkZrObXFsruHAyCsdlw2?alt=media&token=b4f16880-b2b4-43bd-b38f-9d3b7b19e330"), dimension: 64)
    }
}
