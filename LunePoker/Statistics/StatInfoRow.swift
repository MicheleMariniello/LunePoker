//
//  StatInfoRow.swift
//  LunePoker
//
//  Created by Michele Mariniello on 31/03/25.
//

import SwiftUI

// Riga per le statistiche generali
struct StatInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
        }
    }
}
