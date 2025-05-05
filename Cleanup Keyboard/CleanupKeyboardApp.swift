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
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
