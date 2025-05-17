//
//  AccessibilityMonitor.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 17/05/25.
//

import Foundation
import Cocoa
import Combine

final class AccessibilityMonitor: ObservableObject {
    @Published private(set) var hasAccessibilityPermission = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .map { [weak self] _ in
                guard let self else { return false }
                
                return self.checkAccessibilityPermission()
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasAccessibilityPermission, on: self)
            .store(in: &cancellables)
    }
    
    func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options)
    }
    
    func openAccessibilityPreferences() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
}
