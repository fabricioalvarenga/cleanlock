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
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
//            if contentViewModel.hasAccessibilityPermission {
                ZStack {
                    VStack {
                        TitleView()
                            .customViewStyle(geometry: geometry)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        ConfigurationView()
                            .customViewStyle(geometry: geometry)
                    }
                    .opacity(contentViewModel.titleViewOpacity)
                    .zIndex(inputManager.isCleaning ? 0 : 1)
                    
                    VStack {
                        KeyboardView(geometry: geometry)
                            .customViewStyle(geometry: geometry)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        CleaningView()
                            .customViewStyle(geometry: geometry)
                    }
                    .opacity(contentViewModel.cleaningViewOpacity)
                    .zIndex(inputManager.isCleaning ? 1 : 0)
                }
//            } else {
//                EmptyView()
//            }
        }
        .onAppear {
            // Inicializa os estados de opacidade baseados no estado do inputManager
            contentViewModel.setTitleViewOpacity(inputManager.isCleaning ? 0.0 : 1.0)
            contentViewModel.setCleaningViewOpacity(inputManager.isCleaning ? 1.0 : 0.0)
        }
        .onChange(of: windowFocusMonitor.isKeyWindow) { _, isKeyWindow in
            if isKeyWindow {
                contentViewModel.checkAccessibilityPermission()
            }
        }
        .onChange(of: inputManager.isCleaning) { _, isCleaning in
            if isCleaning {
                withAnimation(.smooth(duration: 0.5)) { contentViewModel.setTitleViewOpacity(0.0) }
                withAnimation(.smooth(duration: 0.5)) { contentViewModel.setCleaningViewOpacity(1.0) }
            } else {
                // Atrasa a transição entre as telas apenas para que o usuário
                // possa perceber a mudança de cor dos botões Shift desenhados na tela
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    withAnimation(.smooth(duration: 0.5)) { contentViewModel.setTitleViewOpacity(1.0) }
                    withAnimation(.smooth(duration: 0.5)) { contentViewModel.setCleaningViewOpacity(0.0) }
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

fileprivate extension View {
    func customViewStyle(geometry: GeometryProxy) -> some View {
        self
            .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.4725)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)
    }
}

#Preview {
    ContentView()
        .tint(Color.customAccentColor)
        .environmentObject(InputBlockingManager())
}
