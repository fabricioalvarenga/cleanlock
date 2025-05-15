//
//  CleaningView.swift
//  CleanLock
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
            .foregroundStyle(.secondary)
            .padding(.vertical)
            
            HStack {
                ProminentRoundedRectangle(color: (inputManager.isCleaning && !inputManager.isLeftShiftKeyPressed) ? .black : Color.customAccentColor)
                    .frame(width: 100, height: 80)
                    .overlay(Label("Shift L", systemImage: "shift.fill")
                        .foregroundStyle(Color.white))
                
                ProminentRoundedRectangle(color: (inputManager.isCleaning && !inputManager.isRightShiftKeyPressed) ? .black : Color.customAccentColor)
                    .frame(width: 100, height: 80)
                    .overlay(Label("Shift R", systemImage: "shift.fill")
                        .foregroundStyle(Color.white))
             }
        }
        .onChange(of: inputManager.areBothShiftKeysPressed) { _, pressed in
            if pressed {
                inputManager.stopCleaning()
            }
        }
    }
}

#Preview {
    CleaningView()
        .environmentObject(InputBlockingManager())
        .padding()
}
