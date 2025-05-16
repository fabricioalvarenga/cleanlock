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
    let manager = eventInfo.manager
    
    switch eventType {
    case .keyboard:
        // Verifica se é um evento definido pelo sistema (systemDefined)
        // As teclas de brilho, volume e demais teclas de mídias são controladas por ese tipo de evento
        if type == manager.systemDefinedEventType {
            //            let data = event.getIntegerValueField(CGEventField(rawValue: 45)!)
            
            //            let keyFlags = Int32((data & 0xFFFF0000) >> 16)
            //            let keyData = (data & 0xFFFF)
            //            let keyState = (keyFlags & 0xFF00) >> 8
            
            //            if ((keyData & 0xFF) == 7) || // Volume Up
            //                ((keyData & 0xFF) == 8) || // Volume Down
            //                ((keyData & 0xFF) == 3) { // Mute
            //
            //                let keyDown = keyState & 0x1
            //                let keyCode = keyData & 0xFF
            //
            //                print("Tecla de Volume \(keyCode): \(keyDown == 1 ? "Pressionada" : "Liberada")")
            //            }
        }
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        // Faz o tratamento de retorno para todas as teclas especiais
        if type == .flagsChanged {
            if keyCode == 56 || keyCode == 60 { // Teclas Shift (esquerda e direita)
                switch keyCode {
                case 56: manager.isLeftShiftKeyPressed = flags.contains(.maskShift)
                case 60: manager.isRightShiftKeyPressed = flags.contains(.maskShift)
                default: break
                }
                
                manager.setPressedKeyCodeValue(keyCode)
                
                return Unmanaged.passRetained(event)
            }
            else if (keyCode == 57 && flags.contains(.maskAlphaShift)) || // Tecla Caps Lock
                        (keyCode == 63 && flags.contains(.maskSecondaryFn)) || // Tecla Fn
                        (keyCode == 59 && flags.contains(.maskControl)) || // Tecla Control
                        (keyCode == 58 && flags.contains(.maskAlternate)) || // Tecla Option (left)
                        (keyCode == 61 && flags.contains(.maskAlternate)) || // Tecla Option (right)
                        (keyCode == 55 && flags.contains(.maskCommand)) || // Tecla Command (left)
                        (keyCode == 54 && flags.contains(.maskCommand)) { // Tecla Command (right)
                manager.setPressedKeyCodeValue(keyCode)
            }
        }
        
        // Se a tecla "Seta para Cima" for pressionada, retorna o código da tecla "Seta para Baixo",
        // pois as duas estão desenhadas na mesma tecla no teclado virtual
        // Do contrário, retorna o código de qualquer outra tecla que tenha sido pressionada
        if type == .keyDown {
            if keyCode == 126 {
                manager.setPressedKeyCodeValue(125)
            } else {
                manager.setPressedKeyCodeValue(keyCode)
            }
        }
        
        if manager.isKeyboardLocked {
            return nil
        }
    case .trackpad:
        if type == .leftMouseDown || type == .rightMouseDown {
            manager.setTrackpadPressed(true)
        }
        
        if manager.isTrackpadLocked {
            return nil
        }
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
    @Published var isTrackpadPressed = false
    @Published var pressedKeyCode: Int64?

    private var keyboardTapLockEvent: CFMachPort?
    private var trackpadTapLockEvent: CFMachPort?
    private var keyboardRunLoopSource: CFRunLoopSource?
    private var trackpadRunLoopSource: CFRunLoopSource?
    private var keyboardEventInfo: TapEventInfo?
    private var trackpadEventInfo: TapEventInfo?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Tipo 14 é para eventos definidos pelo sistema (systemDefined) - teclas especiais (caps lock, volume, brilho, etc)
    let systemDefinedEventType = CGEventType(rawValue: 14)!
    
    // Tamanhos relativos das teclas
    let standardKeyWidth: CGFloat = 1.0
    let specialKeyWidths: [String: CGFloat] = [
        "esc": 1.6,
        "delete": 1.6,
        "tab": 1.6,
        "caps": 1.875,
        "return": 1.875,
        "shift l": 2.45,
        "shift r": 2.45,
        "command l": 1.3,
        "command r": 1.3,
        "": 5.6,  // Barra de espaço
    ]
    
    // Layout dos teclados ANSI EUA
    let keys: [[(Int64, String)]] =
    [
        [(53, "esc"), (1001, "F1"), (1002, "F2"), (160, "F3"), (177, "F4"), (176, "F5"), (178, "F6"), (1003, "F7"),
         (1004, "F8"), (1005, "F9"), (1006, "F10"), (1007, "F11"), (1008, "F12"), (1009, "on")],
        
        [(50, "`"), (18, "1"), (19, "2"), (20, "3"), (21, "4"), (23, "5"), (22, "6"), (26, "7"),
         (28, "8"), (25, "9"), (29, "0"), (27, "-"), (24, "="), (51, "delete")],
        
        [(48, "tab"), (12, "Q"), (13, "W"), (14, "E"), (15, "R"), (17, "T"), (16, "Y"),
         (32, "U"), (34, "I"), (31, "O"), (35, "P"), (33, "["), (30, "]"), (42, "\\")],
        
        [(57, "caps"), (0, "A"), (1, "S"), (2, "D"), (3, "F"), (5, "G"), (4, "H"),
         (38, "J"), (40, "K"), (37, "L"), (41, ";"), (39, "'"), (36, "return")],
        
        [(56, "shift l"), (6, "Z"), (7, "X"), (8, "C"), (9, "V"), (11, "B"), (45, "N"),
         (46, "M"), (43, ","), (47, "."), (44, "/"), (60, "shift r")],
        
        [(63, "fn"), (59, "control"), (58, "option l"), (55, "command l"), (49, ""),
         (54, "command r"), (61, "option r"), (123, "←"), (125, "↑↓"), (124, "→")],
    ]
    
    init() {
        Publishers.CombineLatest($isLeftShiftKeyPressed, $isRightShiftKeyPressed)
            .map { $0 && $1 }
            .assign(to: \.areBothShiftKeysPressed, on: self)
            .store(in: &cancellables)
        
        $isCleaning
            .map(\.self)
            .sink { [weak self] isCleaning in
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
    
    deinit {
        isCleaning = false
        
        keyboardEventInfo = nil
        keyboardTapLockEvent = nil
        keyboardRunLoopSource = nil
        
        trackpadEventInfo = nil
        trackpadTapLockEvent = nil
        trackpadRunLoopSource = nil
    }
    
    func findKeyLabel(for keyCode: Int64) -> String? {
        return keys.flatMap { $0 }.first { $0.0 == keyCode }?.1
    }
    
    func setPressedKeyCodeValue(_ keyCode: Int64?) {
        self.pressedKeyCode = keyCode
    }
    
    func setTrackpadPressed(_ isPressed: Bool) {
        self.isTrackpadPressed = isPressed
    }
   
    func startCleaning() {
        isCleaning = true
    }
    
    func stopCleaning() {
        isCleaning = false
    }
    
    private func startMonitoring() {
        startKeyboardMonitoring()
        startTrackpadMonitoring()
    }
    
    private func stopMonitoring() {
        stopKeyboardMonitoring()
        stopTrackpadMonitoring()
    }
   
    private func startKeyboardMonitoring() {
        var eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue) |
        CGEventMask(1 << CGEventType.keyUp.rawValue) |
        CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        
        // Eventos definidos pelo sistema (systemDefined) para teclas especiais (volume, brilho, etc)
        eventMask = eventMask | (1 << systemDefinedEventType.rawValue)
        
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
        
        keyboardRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), keyboardRunLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
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
        
        trackpadRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), trackpadRunLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func stopKeyboardMonitoring() {
        if let keyboardTapLockEvent {
            CGEvent.tapEnable(tap: keyboardTapLockEvent, enable: false)
        }
        
        if let keyboardRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), keyboardRunLoopSource, .commonModes)
        }
        
        keyboardTapLockEvent = nil
        keyboardRunLoopSource = nil
    }

    private func stopTrackpadMonitoring() {
         // Mostra o ponteiro do trackpad/mouse
        CGDisplayShowCursor(CGMainDisplayID())
        
        if let trackpadTapLockEvent {
            CGEvent.tapEnable(tap: trackpadTapLockEvent, enable: false)
        }
        
        if let trackpadRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), trackpadRunLoopSource, .commonModes)
        }
        
        trackpadTapLockEvent = nil
        trackpadRunLoopSource = nil
     }
}
