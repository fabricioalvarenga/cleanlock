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

                Text("Keyboard Cleaner")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Bloqueie o teclado e o trackpad para limpeza fácil")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            Form {
                Section("Configurações") {
                    Toggle("Bloquear Teclado", systemImage: "keyboard", isOn: $inputManager.isKeyboardLocked)
                        .toggleStyle(.switch)
                        .onChange(of: inputManager.isKeyboardLocked) { 
                            inputManager.configureKeyboardState()
                        }

                    Toggle("Bloquear Trackpad/Mouse", systemImage: "rectangle.and.hand.point.up.left", isOn: $inputManager.isTrackpadLocked)
                        .toggleStyle(.switch)
                        .onChange(of: inputManager.isTrackpadLocked) {
                            inputManager.configureTrackpadState()
                        }
                }
            }
            .formStyle(.grouped)
        }
        .onAppear {
            checkAccessibilityPermissions()
        }
       .onChange(of: inputManager.areBothShiftKeysPressed) { _, bothShiftKeysPressed in
            if bothShiftKeysPressed {
                inputManager.isKeyboardLocked = false
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
