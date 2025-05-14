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
    
    private var cancellables = Set<AnyCancellable>()

    // Timer para verificar a cada intervalo se existem permissões de acessibilidade ou se elas foram canceladas
    var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    init() {
        // Faz a primeira checagem de permissões de acessibilidade e configura o timer para chegar novamente a cada intervalo de tempo
        checkAccessibilityPermission()
        
        timer.sink { _ in
            self.checkAccessibilityPermission()
        }
        .store(in: &cancellables)
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
}
