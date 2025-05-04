//
//  ContentView.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 03/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var inputManager = InputBlockingManager()
    @State var showAlert = false

    var body: some View {
        VStack {
            VStack {
                Image(systemName: "macbook")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()

                Text("Limpeza do Macbook")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Bloqueie o teclado e o trackpad antes de realizar a limpeza")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            Form {
                Section("Configurações") {
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
                    Text("Para destravar o teclado ou o trackpad, pressione as teclas Shift (direita e esquerda) simultaneamente.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
            }
            .formStyle(.grouped)
            
        }
        .onAppear {
            checkAccessibilityPermissions()
        }
       .onChange(of: inputManager.areBothShiftKeysPressed) { _, pressed in
           if pressed {
               inputManager.stopCleaning()
           }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Permissões Necessárias"),
                message: Text("Este aplicativo precisa de permissões de acessibilidade para funcionar. Por favor, vá em Preferências do Sitema > Segurança e Privacidade > Acessibilidade e adicione este aplicativo à lista."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            showAlert = true
        }
    }
}

#Preview {
    ContentView()
}
