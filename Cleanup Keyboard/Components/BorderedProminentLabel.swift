//
//  BorderedProminentLabel.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 06/05/25.
//

import SwiftUI

struct BorderedProminentLabel: View {
    var text: String?
    var textColor: Color?
    var imageName: String?
    var backgroundColor: Color?
    
    var body: some View {
        Label {
            Text(text ?? "")
                .font(.headline)
                .foregroundColor(textColor ?? .primary)
        } icon: {
            Image(systemName: imageName ?? "")
                .foregroundColor(textColor ?? .primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor ?? .accentColor)
        )
    }
}

#Preview {
    BorderedProminentLabel()
}
