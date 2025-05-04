//
//  Cleanup_KeyboardApp.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 03/05/25.
//

import SwiftUI

@main
struct Cleanup_KeyboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 350, height: 350)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
