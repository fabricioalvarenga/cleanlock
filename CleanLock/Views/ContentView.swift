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
    @EnvironmentObject private var accessibilityMonitor: AccessibilityMonitor

    @StateObject private var windowFocusMonitor = WindowFocusMonitor()
    
    @State private var path: [Route] = []
    @State private var showAlert = false
    
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
            .onAppear {
                // Caso a janela do aplicativo seja fechada e reaberta, o app sempre retornar para a ContentView
                // Então, é necessário garantir que a opacidade esteja definida corretamente
                contentViewModel.setContentViewOpacity(1.0)
            }
            .onChange(of: windowFocusMonitor.isKeyWindow) { _, isKeyWindow in
                if isKeyWindow {
                    // Adiciona um pequeno atraso na checagem para evitar: 'Update NavigationRequestObserver tried to update multiple times per frame'
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showAlert = !accessibilityMonitor.checkAccessibilityPermission()
                        
                    }
                }
            }
            .onChange(of: inputManager.isCleaning) { _, isCleaning in
                if isCleaning {
                    // Adiciona um pequeno atraso na checagem para evitar: 'Update NavigationRequestObserver tried to update multiple times per frame'
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        contentViewModel.setContentViewOpacity(0.0)
                        contentViewModel.setKeyboardViewOpacity(1.0)
                    }
                } else {
                    // Atrasa a transição entre as telas apenas para que o usuário
                    // possa perceber a mudança de cor dos botões Shift desenhados na tela
                    // E tambmém para evitar: 'Update NavigationRequestObserver tried to update multiple times per frame'
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        contentViewModel.setContentViewOpacity(1.0)
                        contentViewModel.setKeyboardViewOpacity(0.0)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Permissões Necessárias"),
                    message: Text("Este aplicativo precisa de permissão de acessibilidade para conseguir bloquear o teclado e o trackpad. Você será levado às Preferências do Sistema para conceder a permissão necessária."),
                    primaryButton: .default(Text("Abrir Preferências"),
                                            action: { accessibilityMonitor.openAccessibilityPreferences() }),
                    secondaryButton: .cancel(Text("Negar Permissão"),
                                             action: { NSApplication.shared.terminate(nil) }))
            }
        }
    }
}
