//
//  aaa.swift
//  LunePoker
//
//  Created by Michele Mariniello on 08/06/25.
//

import SwiftUI

struct HorizontalPicker<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
    var title: String
    @Binding var selection: T
    var options: [T]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options, id: \.self) { option in
                        Text(option.rawValue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selection == option ? Color.accent : Color.gray.opacity(0.2))
                            .foregroundColor(selection == option ? .black : .white)
                            .cornerRadius(20)
                            .onTapGesture {
                                selection = option
                            }
                    }
                }
                .tint(.orange)
            }
        }
        
    }
}

//#Preview {
//    HorizontalPicker<<#T: CaseIterable & Hashable & RawRepresentable#>>(title: <#String#>, selection: <#Binding<_>#>, options: <#[_]#>)
//}
