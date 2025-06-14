//
//  DeleteWarningHeader.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Warning Header Component
struct DeleteWarningHeader: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Danger Zone")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .padding(.top, 20)
    }
}

#Preview {
    DeleteWarningHeader()
}
