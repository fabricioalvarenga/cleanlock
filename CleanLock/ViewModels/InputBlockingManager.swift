//
//  KeyboardManager.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 03/05/25.
//

import Foundation
import Quartz
import Combine

// Esta função de callback deve ficar fora do escopo da classe ou o seguinte erro aparecerá:
// A C function pointer can only be formed from a reference to a 'func' or a literal closure
fileprivate func tapEventCallback(proxy: CGEventTapProxy,
                      type: CGEventType,
                      event: CGEvent,
                      refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon else {
        return Unmanaged.passRetained(event)
    }
    
    let eventInfo = Unmanaged<TapEventInfo>.fromOpaque(refcon).takeUnretainedValue()
    let eventType = eventInfo.eventType
    let monitor = eventInfo.manager
    
    switch eventType {
    case .keyboard:
        // Verifica se é um evento definido pelo sistema (systemDefined) para controle de mídia/volume
//        if type == monitor.systemMidiaControlEventType {
//            let data = event.getIntegerValueField(.eventSourceUnixProcessID)
//            let keyFlags = Int32((data & 0xFFFF0000) >> 16)
//            let keyData = (data & 0xFFFF)
//            let keyState = (keyFlags & 0xFF00) >> 8
//            
//            if ((keyData & 0xFF) == 7) || // Volume Up
//                ((keyData & 0xFF) == 8) || // Volume Down
//                ((keyData & 0xFF) == 3) { // Mute
//                
//                let keyDown = keyState & 0x1
//                let keyCode = keyData & 0xFF
//                
//                print("Tecla de Volume \(keyCode): \(keyDown == 1 ? "Pressionada" : "Liberada")")
//                
//                return nil
//            }
//        }
        
        if type == .flagsChanged {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            
            if keyCode == 56 || keyCode == 60 { // Teclas Shift (esquerda e direita)
                switch keyCode {
                case 56: monitor.isLeftShiftKeyPressed = flags.contains(.maskShift)
                case 60: monitor.isRightShiftKeyPressed = flags.contains(.maskShift)
                default: break
                }
                return Unmanaged.passRetained(event)
            }
        }
        
        if monitor.isKeyboardLocked { return nil }
    case .trackpad:
        if monitor.isTrackpadLocked { return nil }
    }
    
    return Unmanaged.passRetained(event)
}

fileprivate enum TapEventType {
    case keyboard
    case trackpad
}

fileprivate class TapEventInfo {
    var manager: InputBlockingManager
    var eventType: TapEventType
    
    init(manager: InputBlockingManager, eventType: TapEventType) {
        self.manager = manager
        self.eventType = eventType
    }
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
    private var keyboardEventInfo: TapEventInfo?
    private var trackpadEventInfo: TapEventInfo?
    private var shiftKeysTapEvent: CFMachPort?
    private var cancellables = Set<AnyCancellable>()
    
    // Tipo 14 é para eventos definidos pelo sistema (systemDefined) - teclas especiais (volume, brilho, etc)
    let systemMidiaControlEventType = CGEventType(rawValue: 14)!
        
   init() {
        Publishers.CombineLatest($isLeftShiftKeyPressed, $isRightShiftKeyPressed)
            .map { $0 && $1 }
            .assign(to: \.areBothShiftKeysPressed, on: self)
            .store(in: &cancellables)
        
        $isCleaning.map(\.self).sink { [weak self] isCleaning in
            if isCleaning {
                self?.startMonitoring()
            } else {
                self?.isLeftShiftKeyPressed = false
                self?.isRightShiftKeyPressed = false
                self?.stopMonitoring()
            }
        }
        .store(in: &cancellables)
    }
    
    deinit { isCleaning = false }
    
    func startCleaning() { isCleaning = true }
    
    func stopCleaning() { isCleaning = false }
    
    private func startMonitoring() {
        startKeyboardMonitoring()
        startTrackpadMonitoring()
    }
   
    private func startKeyboardMonitoring() {
        var eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue) |
        CGEventMask(1 << CGEventType.keyUp.rawValue) |
        CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        
        // Eventos definidos pelo sistema (systemDefined) para teclas especiais (volume, brilho, etc)
        eventMask = eventMask | (1 << systemMidiaControlEventType.rawValue)
        
        // Cria estrutura de informações do evento para que o mesmo callback
        // possa identificar se se trata de um evento de teclado ou trackpad
        keyboardEventInfo = TapEventInfo(manager: self, eventType: .keyboard)
        
        keyboardTapLockEvent = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                                 place: .headInsertEventTap,
                                                 options: .defaultTap,
                                                 eventsOfInterest: eventMask,
                                                 callback: tapEventCallback,
                                                 userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(keyboardEventInfo!).toOpaque()))
        
        guard let eventTap = keyboardTapLockEvent else { return }
        
        enableTapEvent(eventTap)
    }
    
    private func startTrackpadMonitoring() {
        // Esconde o ponteiro do trackpad/mouse
        if isTrackpadLocked {
            CGDisplayHideCursor(CGMainDisplayID())
        }
        
        var eventMask = CGEventMask(1 << CGEventType.leftMouseDown.rawValue) |
        CGEventMask(1 << CGEventType.leftMouseUp.rawValue) |
        CGEventMask(1 << CGEventType.leftMouseDragged.rawValue)
        
        eventMask = eventMask |
        CGEventMask(1 << CGEventType.rightMouseDown.rawValue) |
        CGEventMask(1 << CGEventType.rightMouseUp.rawValue) |
        CGEventMask(1 << CGEventType.rightMouseDragged.rawValue)
        
        eventMask = eventMask |
        CGEventMask(1 << CGEventType.otherMouseDown.rawValue) |
        CGEventMask(1 << CGEventType.otherMouseUp.rawValue) |
        CGEventMask(1 << CGEventType.otherMouseDragged.rawValue)
        
        eventMask = eventMask |
        CGEventMask(1 << CGEventType.mouseMoved.rawValue) |
        CGEventMask(1 << CGEventType.scrollWheel.rawValue)
        
        // Cria estrutura de informações do evento para que o mesmo callback
        // possa identificar se se trata de um evento de teclado ou trackpad
        trackpadEventInfo = TapEventInfo(manager: self, eventType: .trackpad)
        
        trackpadTapLockEvent = CGEvent.tapCreate(tap: .cghidEventTap,
                                                 place: .headInsertEventTap,
                                                 options: .defaultTap,
                                                 eventsOfInterest: eventMask,
                                                 callback: tapEventCallback,
                                                 userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(trackpadEventInfo!).toOpaque()))

        guard let eventTap = trackpadTapLockEvent else { return }
        
        enableTapEvent(eventTap)
    }
    
    private func enableTapEvent(_ eventTap: CFMachPort) {
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func stopMonitoring() {
        stopKeyboardMonitoring()
        stopTrackpadMonitoring()
    }
    
    private func stopKeyboardMonitoring() {
        if let eventTap = keyboardTapLockEvent {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        keyboardTapLockEvent = nil
    }

    private func stopTrackpadMonitoring() {
         // Mostra o ponteiro do trackpad/mouse
        CGDisplayShowCursor(CGMainDisplayID())
        
        if let eventTap = trackpadTapLockEvent {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        trackpadTapLockEvent = nil
     }
}
