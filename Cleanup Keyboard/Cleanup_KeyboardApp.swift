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
                .frame(minWidth: 500, minHeight: 400)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
