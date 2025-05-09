//
//  ProminentRoundedRectangle.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 08/05/25.
//

import SwiftUI

struct ProminentRoundedRectangle: View {
    var color: Color?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [(color ?? .primary).opacity(1.0),
                                                (color ?? .primary),
                                                (color ?? .primary).opacity(0.9)]),
                    startPoint: .top,
                    endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke((color ?? .primary).opacity(0.7), lineWidth: 0.5))
            .shadow(color: (color ?? .primary).opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ProminentRoundedRectangle(color: Color.customAccentColor)
        .frame(width: 100, height: 100)
        .padding()
}
