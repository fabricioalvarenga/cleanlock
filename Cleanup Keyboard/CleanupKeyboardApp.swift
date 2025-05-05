//
//  Cleanup_KeyboardApp.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 03/05/25.
//

import SwiftUI

@main
struct CleanupKeyboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 575, height: 500)
                // Faz com que a janela do aplicativo fique no topo (em frente a outras janelas de outros aplicativos)
                .background(WindowAccessor { window in
                    window?.level = .floating
                })
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
