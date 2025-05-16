//
//  ContentViewController.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 09/05/25.
//

import SwiftUI
import Cocoa
import Combine

class ContentViewModel: ObservableObject {
    @Published var hasAccessibilityPermission = false
    @Published var showAccessibilityPermissionAlert = false
    @Published var contentViewOpacity = 1.0
    @Published var keyboardViewOpacity = 0.0
    
    func checkAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        hasAccessibilityPermission = AXIsProcessTrustedWithOptions(options)
        
        if !hasAccessibilityPermission {
            showAccessibilityPermissionAlert = true
        }
    }
    
    func openAccessibilityPreferences() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
    
    func setContentViewOpacity(_ opacity: CGFloat) {
        withAnimation {
            contentViewOpacity = opacity
        }
    }
    
    func setKeyboardViewOpacity(_ opacity: CGFloat) {
        withAnimation {
            keyboardViewOpacity = opacity
        }
    }
}
