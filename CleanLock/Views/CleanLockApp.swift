//
//  Cleanup_KeyboardApp.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 03/05/25.
//

import SwiftUI

@main
struct CleanLockApp: App {
    @StateObject private var contentViewModel = ContentViewModel()
    @StateObject private var inputManager = InputBlockingManager()
    @StateObject private var accessbilityMonitor = AccessibilityMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contentViewModel)
                .environmentObject(inputManager)
                .environmentObject(accessbilityMonitor)
                .frame(width: 600, height: 600)
                .tint(Color.customAccentColor)
                // Faz com que a janela do aplicativo fique no topo (em frente a outras janelas de outros aplicativos)
//                .background(WindowAccessor { window in
//                    guard let window = window else { return }
//                    // Mantém a janela sempre visível
//                    window.level = .floating
//                    // Torna a janela principal e ativa
//                    window.makeKeyAndOrderFront(nil)
//                    // Reforça que deve ficar na frente das outras janelas
//                    window.orderFrontRegardless()
//                })
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
