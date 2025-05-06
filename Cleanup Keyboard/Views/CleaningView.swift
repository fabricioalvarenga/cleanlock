//
//  CleaningView.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 05/05/25.
//

import SwiftUI

struct CleaningView: View {
    @EnvironmentObject private var inputManager: InputBlockingManager
    
    var body: some View {
        VStack {
            Text("""
                 Pressione as teclas Shift (direita e esquerda)
                 simultaneamente para destravar
                 """)
            .multilineTextAlignment(.center)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .padding(.vertical)
            
            HStack(spacing: 20) {
                BorderedProminentLabel(text: "Shift L",
                                       textColor: .white,
                                       imageName: "shift.fill",
                                       backgroundColor: (inputManager.isCleaning && !inputManager.isLeftShiftKeyPressed) ? .black : .accentColor)
                .padding(.horizontal, 50)
                Spacer()
                BorderedProminentLabel(text: "Shift R",
                                       textColor: .white,
                                       imageName: "shift.fill",
                                       backgroundColor: (inputManager.isCleaning && !inputManager.isRightShiftKeyPressed) ? .black : .accentColor)
                .padding(.horizontal, 50)
            }
        }
    }
}

#Preview {
    CleaningView()
}
