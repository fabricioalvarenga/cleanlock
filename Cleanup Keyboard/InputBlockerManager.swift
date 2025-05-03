//
//  KeyboardManager.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 03/05/25.
//

import Foundation
import Quartz

class InputBlockerManager: ObservableObject {
    @Published var isKeyboardBlocked = false
    @Published var isTrackpadBlocked = false

    private var countdown = 5
    private var timer: Timer? = nil
    private var keyboardMonitor: CFMachPort?
    private var trackpadMonitor: CFMachPort?

    func configureKeyboardState() {
        if isKeyboardBlocked {
            print("Teclado bloqueado...")
            setupKeyboardMonitor()
            startCountdown()
        } else {
            print("Teclado desbloqueado...")
            removeKeyboardMonitor()
        }
    }

    func configureTrackpadState() {
        if isTrackpadBlocked {
            print("Trackpad bloqueado...")
            setupTrackpadMonitor()
            startCountdown()
        } else {
            print("Trackpad desbloqueado...")
            removeTrackpadMonitor()
        }
    }

    private func setupKeyboardMonitor() {
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue) |
                        CGEventMask(1 << CGEventType.keyUp.rawValue)

        keyboardMonitor = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (_, _, event, _) -> Unmanaged<CGEvent>? in 
                return nil
            },
            userInfo: nil
        )

        if let eventTap = keyboardMonitor {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    private func setupTrackpadMonitor() {
        var eventMask = CGEventMask(1 << CGEventType.leftMouseDown.rawValue) |
                        CGEventMask(1 << CGEventType.leftMouseUp.rawValue) |
                        CGEventMask(1 << CGEventType.leftMouseDragged.rawValue) |
                        CGEventMask(1 << CGEventType.rightMouseDown.rawValue) |
                        CGEventMask(1 << CGEventType.rightMouseUp.rawValue) |
                        CGEventMask(1 << CGEventType.rightMouseDragged.rawValue)

        eventMask = eventMask |
                    CGEventMask(1 << CGEventType.mouseMoved.rawValue) |
                    CGEventMask(1 << CGEventType.otherMouseDown.rawValue) |
                    CGEventMask(1 << CGEventType.otherMouseUp.rawValue) |
                    CGEventMask(1 << CGEventType.otherMouseDragged.rawValue) |
                    CGEventMask(1 << CGEventType.scrollWheel.rawValue)

        trackpadMonitor = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (_, _, event, _) -> Unmanaged<CGEvent>? in 
                return nil
            },
            userInfo: nil
        )

        if let eventTap = trackpadMonitor {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    private func removeKeyboardMonitor() {
        if let eventTap = keyboardMonitor {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        keyboardMonitor = nil
    }

    private func removeTrackpadMonitor() {
        if let eventTap = trackpadMonitor {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        trackpadMonitor = nil
     }

    private func startCountdown() {
        countdown = 5
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in 
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.isKeyboardBlocked = false
                self.isTrackpadBlocked = false
                self.stopCountdown()
            }
        }
    }

    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
        countdown = 5
    }
}
