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
                Toggle(isOn: $inputManager.isKeyboardLocked) {
                    HStack {
                        Image(systemName: "keyboard")
                            .foregroundColor(Color.customAccentColor)
                       
                        Text("Bloquear Teclado")
                    }
                    
                }
                .toggleStyle(.switch)
                
                Toggle(isOn: $inputManager.isTrackpadLocked) {
                    HStack {
                        Image(systemName: "rectangle.and.hand.point.up.left")
                            .foregroundColor(Color.customAccentColor)
                        
                        Text("Bloquear Trackpad")
                    }
                }
                .toggleStyle(.switch)
               
                HStack {
                    Spacer()
                    
                    Button {
                        inputManager.startCleaning()
                    } label: {
                        Label("Iniciar Limpeza", systemImage: "drop.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large )
                    
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
