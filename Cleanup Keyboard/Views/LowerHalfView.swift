//
//  MainView.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 05/05/25.
//

import SwiftUI

struct LowerHalfView: View {
    @EnvironmentObject private var inputManager: InputBlockingManager
    @State private var opacity = 1.0
    
    var body: some View {
        Form {
            Section("Configurações") {
                //            Section("Configurações") {
                Toggle("Bloquear Teclado", systemImage: "keyboard", isOn: $inputManager.isKeyboardLocked)
                    .toggleStyle(.switch)
                
                Toggle("Bloquear Trackpad", systemImage: "rectangle.and.hand.point.up.left", isOn: $inputManager.isTrackpadLocked)
                    .toggleStyle(.switch)
                
                HStack {
                    Spacer()
                    Button("Iniciar Limpeza") {
                        inputManager.startCleaning()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .disabled((!inputManager.isKeyboardLocked && !inputManager.isTrackpadLocked) || inputManager.isCleaning)
            }
            HStack {
                Spacer()
                Text("""
                    Para destravar o teclado e o trackpad, pressione
                    as teclas Shift (direita e esquerda) simultaneamente.
                    """)
                .multilineTextAlignment(.center)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                Spacer()
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
    }
}

#Preview {
    LowerHalfView()
}
