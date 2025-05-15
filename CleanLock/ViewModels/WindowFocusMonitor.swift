//
//  WindowFocusMonitor.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 14/05/25.
//

import Foundation
import AppKit
import Combine

class WindowFocusMonitor: ObservableObject {
    @Published var isKeyWindow = false // Verifica se a janela está recebendo eventos de teclado e, sim, significa que ela tem o foco
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)
            .sink { [weak self] notification in
                if let window = notification.object as? NSWindow {
                    DispatchQueue.main.async {
                        self?.isKeyWindow = window.isKeyWindow
                    }
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)
             .sink { [weak self] _ in
                 DispatchQueue.main.async {
                     self?.isKeyWindow = false
                 }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
