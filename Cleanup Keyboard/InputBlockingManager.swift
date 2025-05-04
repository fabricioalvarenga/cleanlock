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
func keyboardTapEventCallback(proxy: CGEventTapProxy,
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
    
    if !monitor.isKeyboardLocked {
        return Unmanaged.passRetained(event)
    }
    
    return nil
}

// Esta função de callback deve ficar fora do escopo da classe ou o seguinte erro aparecerá:
// A C function pointer can only be formed from a reference to a 'func' or a literal closure
func trackpadTapEventCallback(proxy: CGEventTapProxy,
                      type: CGEventType,
                      event: CGEvent,
                      refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else {
        return Unmanaged.passRetained(event)
    }
    
    let monitor = Unmanaged<InputBlockingManager>.fromOpaque(refcon).takeUnretainedValue()
    
    if !monitor.isTrackpadLocked {
        return Unmanaged.passRetained(event)
    }
    
    return nil
}

class InputBlockingManager: ObservableObject {
    @Published var isCleaning = false
    @Published var isKeyboardLocked = true
    @Published var isTrackpadLocked = true
    @Published var isLeftShiftKeyPressed = false
    @Published var isRightShiftKeyPressed = false
    @Published var areBothShiftKeysPressed = false

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
        stopKeyboardMonitoring()
        stopTrackpadMonitoring()
    }
    
    func startCleaning() {
        isCleaning = true
        startKeyboardMonitoring()
        startTrackpadMonitoring()
    }
    
    func stopCleaning() {
        isCleaning = false
        stopKeyboardMonitoring()
        stopTrackpadMonitoring()
    }
   
    private func startKeyboardMonitoring() {
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue) |
        CGEventMask(1 << CGEventType.keyUp.rawValue) |
        CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        
        keyboardTapLockEvent = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                                 place: .headInsertEventTap,
                                                 options: .defaultTap,
                                                 eventsOfInterest: eventMask,
                                                 callback: keyboardTapEventCallback,
                                                 userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        guard let eventTap = keyboardTapLockEvent else { return }
        
        tapEventEnable(eventTap)
    }
    
    private func startTrackpadMonitoring() {
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
                                                 callback: trackpadTapEventCallback,
                                                 userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

        guard let eventTap = trackpadTapLockEvent else { return }
        
        tapEventEnable(eventTap)
    }
    
    private func tapEventEnable(_ eventTap: CFMachPort) {
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func stopKeyboardMonitoring() {
        if let eventTap = keyboardTapLockEvent {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        keyboardTapLockEvent = nil
    }

    private func stopTrackpadMonitoring() {
        if let eventTap = trackpadTapLockEvent {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        trackpadTapLockEvent = nil
     }
}
