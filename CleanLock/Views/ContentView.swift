//
//  ContentView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 10/05/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var contentViewModel: ContentViewModel
    @EnvironmentObject private var inputManager: InputBlockingManager
    
    @StateObject private var windowFocusMonitor = WindowFocusMonitor()
    
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                VStack {
                    TitleView()
                        .customViewStyle(viewDimension: geometry.size)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    ConfigurationView(path: $path)
                        .customViewStyle(viewDimension: geometry.size)
                }
            }
            .opacity(contentViewModel.contentViewOpacity)
            .navigationDestination(for: Route.self) { destination in
                switch destination {
                case .keyboardView:
                    KeyboardView(path: $path)
                }
            }
            .onChange(of: windowFocusMonitor.isKeyWindow) { _, isKeyWindow in
                if isKeyWindow {
                    // Adiciona um pequeno atraso na checagem para evitar: 'Update NavigationRequestObserver tried to update multiple times per frame'
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        contentViewModel.checkAccessibilityPermission()
                    }
                }
            }
            .onChange(of: inputManager.isCleaning) { _, isCleaning in
                if isCleaning {
                    // Adiciona um pequeno atraso na checagem para evitar: 'Update NavigationRequestObserver tried to update multiple times per frame'
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        contentViewModel.setContentViewOpacity(0.0)
                        contentViewModel.setKeyboardViewOpacity(1.0)
                    }
                } else {
                    // Atrasa a transição entre as telas apenas para que o usuário
                    // possa perceber a mudança de cor dos botões Shift desenhados na tela
                    // E tambmém para evitar: 'Update NavigationRequestObserver tried to update multiple times per frame'
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        contentViewModel.setContentViewOpacity(1.0)
                        contentViewModel.setKeyboardViewOpacity(0.0)
                    }
                }
            }
            .alert(isPresented: $contentViewModel.showAccessibilityPermissionAlert) {
                Alert(
                    title: Text("Permissões Necessárias"),
                    message: Text("Este aplicativo precisa de permissão de acessibilidade para funcionar. Você será levado às Preferências do Sistema para conceder a permissão necessária."),
                    primaryButton: .default(Text("Abrir Preferências"),
                                            action: { contentViewModel.openAccessibilityPreferences() }),
                    secondaryButton: .cancel(Text("Negar Permissão"),
                                             action: { NSApplication.shared.terminate(nil) }))
            }
        }
    }
}
