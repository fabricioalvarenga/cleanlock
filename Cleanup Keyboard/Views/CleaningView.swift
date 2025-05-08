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
            
            HStack {
                ProminentRoundedRectangle(color: (inputManager.isCleaning && !inputManager.isLeftShiftKeyPressed) ? .black : Color.customAccentColor)
                    .frame(width: 100, height: 80)
                    .overlay(Label("Shift L", systemImage: "shift.fill")
                        .foregroundColor(Color.white))
                    .padding()
                
//                Spacer()
                
                ProminentRoundedRectangle(color: (inputManager.isCleaning && !inputManager.isRightShiftKeyPressed) ? .black : Color.customAccentColor)
                    .frame(width: 100, height: 80)
                    .overlay(Label("Shift R", systemImage: "shift.fill")
                        .foregroundColor(Color.white))
                    .padding()
             }
        }
    }
}

#Preview {
    CleaningView()
        .environmentObject(InputBlockingManager())
        .padding()
}
