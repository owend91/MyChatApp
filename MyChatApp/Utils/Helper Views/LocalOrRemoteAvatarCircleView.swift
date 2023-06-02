//
//  LocalOrRemoteAvatarCircleView.swift
//  MyChatApp
//
//  Created by David Owen on 6/2/23.
//

import SwiftUI

struct LocalOrRemoteAvatarCircleView: View {

    let image: UIImage?
    let imageUrl: String
    let dimension: CGFloat
    let showShadow: Bool
    
    var body: some View {
        if let image {
            LocalAvatarView(image: image, dimension: dimension, showShadow: false)
                .padding(.top, 1)
        } else {
            RemoteAvatarView(url: URL(string: imageUrl), dimension: dimension, showShadow: false)
                .padding(.top, 1)
        }
    }
}

struct LocalOrRemoteAvatarCircleView_Previews: PreviewProvider {
    static var previews: some View {
        LocalOrRemoteAvatarCircleView(image: nil, imageUrl: "", dimension: 50, showShadow: false)
    }
}

fileprivate struct LocalAvatarView: View {
    let image: UIImage
    let dimension: CGFloat
    let showShadow: Bool
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .clipped()
            .frame(width: dimension, height: dimension)
            .clipShape(Circle())
            .overlay {
                RoundedRectangle(cornerRadius: dimension)
                    .stroke(Color(.label), lineWidth: 1)
            }
            .shadow(radius: showShadow ? 5 : 0)
    }
}

fileprivate struct RemoteAvatarView: View {
    let url: URL?
    let dimension: CGFloat
    let showShadow: Bool
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
                    .shadow(radius: showShadow ? 5 : 0)
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                EmptyView()
            }
        }
    }
}
