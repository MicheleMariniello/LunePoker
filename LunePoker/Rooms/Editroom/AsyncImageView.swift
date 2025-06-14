//
//  AsyncImageView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

struct AsyncImageView: View {
    let imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        } placeholder: {
            DefaultRoomIcon()
        }
    }
}

//#Preview {
//    AsyncImageView()
//}
