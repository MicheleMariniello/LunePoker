//
//  DeleteWarningList.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Warning List Component
struct DeleteWarningList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text("•")
                    .foregroundColor(.red)
                Text("All players and their information")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            HStack {
                Text("•")
                    .foregroundColor(.red)
                Text("All match history and results")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            HStack {
                Text("•")
                    .foregroundColor(.red)
                Text("All statistics and analytics")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            HStack {
                Text("•")
                    .foregroundColor(.red)
                Text("Room settings and customizations")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
    }
}

//#Preview {
//    DeleteWarningList()
//}
