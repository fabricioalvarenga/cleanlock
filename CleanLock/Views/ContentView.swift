//
//  ContentView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 10/05/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var contentViewController: ContentViewController
    @EnvironmentObject private var inputManager: InputBlockingManager
    @Environment(\.scenePhase) var scenePhase
    @State private var titleViewOpacity = 1.0
    @State private var cleaningViewOpacity = 1.0
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    TitleView()
                        .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.485)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    ConfigurationView()
                        .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.46)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                .opacity(titleViewOpacity)
                .zIndex(inputManager.isCleaning ? 0 : 1)
                
                VStack {
                    MacBookKeyboardView(geometry: geometry)
                        .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.485)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    
                     Divider()
                        .padding(.horizontal)
                    
                    CleaningView()
                        .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.46)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                .opacity(cleaningViewOpacity)
                .zIndex(inputManager.isCleaning ? 1 : 0)
            }
        }
        .onAppear {
            // Inicializa os estados de opacidade baseados no estado do inputManager
            titleViewOpacity = inputManager.isCleaning ? 0.0 : 1.0
            cleaningViewOpacity = inputManager.isCleaning ? 1.0 : 0.0
        }
        .onChange(of: inputManager.areBothShiftKeysPressed) { _, pressed in
            if pressed { inputManager.stopCleaning() }
        }
        .onChange(of: inputManager.isCleaning) { _, isCleaning in
            if isCleaning {
                withAnimation(.smooth(duration: 0.5)) { titleViewOpacity = 0.0 }
                withAnimation(.smooth(duration: 0.5)) { cleaningViewOpacity = 1.0 }
            } else {
                // Atrasa a transição entre as telas apenas para que o usuário
                // possa perceber a mudança de cor dos botões Shift desenhados na tela
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    withAnimation(.smooth(duration: 0.5)) { titleViewOpacity = 1.0 }
                    withAnimation(.smooth(duration: 0.5)) { cleaningViewOpacity = 0.0 }
                }
            }
        }
        .alert(isPresented: $contentViewController.showAccessibilityPermissionAlert) {
            Alert(
                title: Text("Permissões Necessárias"),
                message: Text("Este aplicativo precisa de permissão de acessibilidade para funcionar. Você será levado às Preferências do Sistema para conceder a permissão necessária."),
                primaryButton: .default(Text("Abrir Preferências"),
                                        action: { contentViewController.openAccessibilityPreferences() }),
                secondaryButton: .cancel(Text("Negar Permissão"),
                                         action: { NSApplication.shared.terminate(nil) }))
        }
    }
    
}

#Preview {
    ContentView()
        .tint(Color.customAccentColor)
        .environmentObject(InputBlockingManager())
}
