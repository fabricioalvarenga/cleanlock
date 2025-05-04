//
//  KeyboardManager.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 03/05/25.
//

import Foundation
import Quartz
import Combine

// Esta função de callback deve ficar fora do escopo da classe ou o seguinte erro aparecerá:
// A C function pointer can only be formed from a reference to a 'func' or a literal closure
func tapEventCallback(proxy: CGEventTapProxy,
                      type: CGEventType,
                      event: CGEvent,
                      refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else {
        return Unmanaged.passRetained(event)
    }
    
    let monitor = Unmanaged<InputBlockingManager>.fromOpaque(refcon).takeUnretainedValue()
    
    if type == .flagsChanged {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        if keyCode == 56 || keyCode == 60 { // Teclas Shift (esquerda e direita)
            let flags = event.flags
            
            if keyCode == 56 {
                monitor.isLeftShiftKeyPressed = flags.contains(.maskShift)
            }
            
            if keyCode == 60 {
                monitor.isRightShiftKeyPressed = flags.contains(.maskShift)
            }
            
            return Unmanaged.passRetained(event)
        }
    }
    
    return nil
}

class InputBlockingManager: ObservableObject {
    @Published var isKeyboardLocked = false
    @Published var isTrackpadLocked = false
    @Published var isLeftShiftKeyPressed = false
    @Published var isRightShiftKeyPressed = false
    @Published var areBothShiftKeysPressed = false

    private var countdown = 30
    private var timer: Timer? = nil
    private var keyboardTapLockEvent: CFMachPort?
    private var trackpadTapLockEvent: CFMachPort?
    private var shiftKeysTapEvent: CFMachPort?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($isLeftShiftKeyPressed, $isRightShiftKeyPressed)
            .map { $0 && $1 }
            .assign(to: \.areBothShiftKeysPressed, on: self)
            .store(in: &cancellables)
    }
    
    deinit {
        unlockKeyboard()
        unlockTrackpad()
    }

    func configureKeyboardState() {
        if isKeyboardLocked {
            print("Teclado bloqueado...")
            lockKeyboard()
            startCountdown()
        } else {
            print("Teclado desbloqueado...")
            unlockKeyboard()
        }
    }

    func configureTrackpadState() {
        if isTrackpadLocked {
            print("Trackpad bloqueado...")
            lockTrackpad()
            startCountdown()
        } else {
            print("Trackpad desbloqueado...")
            unlockTrackpad()
        }
    }
    
    private func lockKeyboard() {
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue) |
                        CGEventMask(1 << CGEventType.keyUp.rawValue) |
                        CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        
        keyboardTapLockEvent = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                                 place: .headInsertEventTap,
                                                 options: .defaultTap,
                                                 eventsOfInterest: eventMask,
                                                 callback: tapEventCallback,
                                                 userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        guard let eventTap = keyboardTapLockEvent else { return }
        
        tapEventEnable(eventTap)
        
//        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
//        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
//        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func lockTrackpad() {
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

        trackpadTapLockEvent = CGEvent.tapCreate(tap: .cghidEventTap,
                                                 place: .headInsertEventTap,
                                                 options: .defaultTap,
                                                 eventsOfInterest: eventMask,
                                                 callback: tapEventCallback,
                                                 userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

        guard let eventTap = trackpadTapLockEvent else { return }
        
        tapEventEnable(eventTap)
    }
    
    private func tapEventEnable(_ eventTap: CFMachPort) {
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func unlockKeyboard() {
        if let eventTap = keyboardTapLockEvent {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        keyboardTapLockEvent = nil
        isLeftShiftKeyPressed = false
        isRightShiftKeyPressed = false
    }

    private func unlockTrackpad() {
        if let eventTap = trackpadTapLockEvent {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        trackpadTapLockEvent = nil
     }

    private func startCountdown() {
        countdown = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in 
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.isKeyboardLocked = false
                self.isTrackpadLocked = false
                self.stopCountdown()
            }
        }
    }

    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
        countdown = 30
    }
}
