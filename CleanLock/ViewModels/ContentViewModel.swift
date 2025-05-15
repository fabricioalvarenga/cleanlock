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
    @Published var titleViewOpacity = 1.0
    @Published var cleaningViewOpacity = 1.0
    
    init() {
        // Faz a primeira checagem de permissões de acessibilidade e configura o timer para chegar novamente a cada intervalo de tempo
//        checkAccessibilityPermission()
    }
   
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
    
    func setTitleViewOpacity(_ opacity: CGFloat) {
        titleViewOpacity = opacity
    }
    
    func setCleaningViewOpacity(_ opacity: CGFloat) {
        cleaningViewOpacity = opacity
    }
}
