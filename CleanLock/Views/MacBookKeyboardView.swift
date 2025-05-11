//
//  KeyboardKeyView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 10/05/25.
//

import SwiftUI

struct MacBookKeyboardView: View {
    @State private var pressedKey: String? = nil
    @State private var trackpadPressed: Bool = false
    
    // Layout dos teclados ANSI EUA
    private let keyboard = [["esc", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "on"],
                            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "delete"],
                            ["tab", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\"],
                            ["caps", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "return"],
                            ["shift", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "shift"],
                            ["fn", "control", "option", "command", "", "command", "option", "←", "↑↓", "→"]]
    
    // Larguras relativas para cada tecla
    private let standardKeyWidth: CGFloat = 1.0
    private let specialKeyWidths: [String: CGFloat] = [
        "esc": 1.45,
        "delete": 1.45,
        "tab": 1.45,
        "caps": 1.775,
        "return": 1.775,
        "shift": 2.325,
        "fn": 1.0,
        "control": 1.0,
        "command": 1.2,
        "": 5.475// Barra de espaço
    ]
    
    private let scaleFactorSpaceBetweenKeys: CGFloat = 0.0035
    var geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 2) {
            // Container do teclado com aparência de baixo relevo
            ZStack {
                // Background do teclado
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.2))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: geometry.size.width * 0.575, height: geometry.size.height * 0.25)
                
                // Conteúdo do teclado
                keyRows(of: keyboard, containerDimension: geometry)
            }
            
            // Trackpad
            trackpadView(containerDimension: geometry)
        }
    }
    
    // Novo componente para o trackpad
    @ViewBuilder
    func trackpadView(containerDimension geometry: GeometryProxy) -> some View {
        Button(action: {
            self.trackpadPressed = true
            // Simula clique no trackpad
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.trackpadPressed = false
            }
        }) {
            ZStack {
                // Fundo do trackpad com baixo relevo
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                
                // Linha divisória sutil no topo do trackpad (como nos MacBooks)
//                VStack {
//                    Spacer().frame(height: 10)
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.1))
//                        .frame(width: 40, height: 1)
//                    Spacer()
//                }
            }
            .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.15)
            .scaleEffect(trackpadPressed ? 0.995 : 1.0)
            .animation(.spring(response: 0.1), value: trackpadPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    func keyRows(of keyboard: [[String]], containerDimension geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.width * scaleFactorSpaceBetweenKeys) {
            ForEach(Array(keyboard.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: geometry.size.width * scaleFactorSpaceBetweenKeys) {
                    ForEach(Array(row.enumerated()), id: \.offset) { keyIndex, key in
                        keyButton(key: key, viewDimension: geometry)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func keyButton(key: String, viewDimension geometry: GeometryProxy) -> some View {
        let keyWidth = specialKeyWidths[key] ?? standardKeyWidth
        
        Button {
            self.pressedKey = key
            // Simula o pressionamento das teclas
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pressedKey = nil
            }
        } label: {
            ZStack {
                // Fundo da tecla com baixo relevo
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.5), lineWidth: 0.6)
                            .shadow(color: .white.opacity(0.05), radius: 0.6, x: 0, y: 0.6)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 0.6, x: 0, y: 0.6)
                
                // Texto da tecla
                Text(keyLabel(for: key))
                    .font(.system(size: geometry.size.height * 0.012125))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
//            .frame(width: keyWidth * geometry.size.width * 0.035, height: geometry.size.height * 0.041225)
            .frame(width: keyWidth * geometry.size.width * 0.035, height: geometry.size.height * 0.035)
            .scaleEffect(pressedKey == key ? 0.95 : 1.0)
            .animation(.spring(response: 0.1), value: pressedKey == key)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Função para retornar o rótulo apropriado para cada tecla
    func keyLabel(for key: String) -> String {
        switch key {
        case "delete":
            return "⌫"
        case "tab":
            return "⇥"
        case "caps":
            return "⇪"
        case "return":
            return "↩"
        case "shift":
            return "⇧"
        case "fn":
            return "fn"
        case "control":
            return "⌃"
        case "option":
            return "⌥"
        case "command":
            return "⌘"
        case "":
            return ""  // Tecla de espaço - fica em branco
        case "←", "↑", "↓", "→":
            return key // Teclas de seta
        case "esc":
            return "esc"
        default:
            return key
        }
    }
}
