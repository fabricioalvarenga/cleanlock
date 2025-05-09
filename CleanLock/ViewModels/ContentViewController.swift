//
//  ContentViewController.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 09/05/25.
//

import SwiftUI
import Cocoa

class ContentViewController: ObservableObject {
    @Published var hasAccessibilityPermission = false
    @Published var showAccessibilityPermissionAlert = false
    
    init() {
        setupActivateNotificationObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    // Monitora quando o aplicativo se torna ativo novamente
    private func setupActivateNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecameActive),
                                               name: NSApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc private func applicationDidBecameActive() {
        checkAccessibilityPermission()
    }
}
