//
//  KeyboardKeyView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 10/05/25.
//

import SwiftUI

struct MacBookKeyboardView: View {
    @EnvironmentObject private var inputManager: InputBlockingManager
    @State private var pressedKey: String? = nil

    // Dimensões relativas
    private var horizontalSpaceBetweenKeys: CGFloat {
        geometry.size.width / 200
    }

    private var verticalSpaceBetweenKeys: CGFloat {
        geometry.size.width / 200
    }

    private var keyboardBackgroundWidth: CGFloat {
        geometry.size.width / 1.75
    }

    private var keyboardBackgroundHeight: CGFloat {
        geometry.size.height / 4.1075
    }

    private var trackpadWidth: CGFloat {
        geometry.size.width / 4
    }

    private var trackpadHeight: CGFloat {
        geometry.size.height / 6.6667
    }
    
    private var keyWidth: CGFloat {
        geometry.size.width / 30
    }
    
    private var keyHeight: CGFloat {
        geometry.size.height / 30
    }

    private var keyLabelSize: CGFloat {
        geometry.size.width / 82.475
    }

    var geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Background do teclado
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.2)) // Cor de fundo mais próxima do alumínio
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black.opacity(0.35), lineWidth: 0.5) // Borda sutil
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2) // Sombra suave para profundidade
                    .frame(width: keyboardBackgroundWidth, height: keyboardBackgroundHeight)
                
                // Conteúdo do teclado
                keyRows(of: inputManager.keyboard, containerDimension: geometry)
            }

            // Trackpad
            trackpadView(containerDimension: geometry)
        }
    }

    @ViewBuilder
    func trackpadView(containerDimension geometry: GeometryProxy) -> some View {
        Button {
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.35), lineWidth: 0.5) // Borda sutil
                )
                .frame(width: trackpadWidth, height: trackpadHeight)
                .scaleEffect(inputManager.isTrackpadPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.1), value: inputManager.isTrackpadPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: inputManager.isTrackpadPressed) { _, trackpadPressed in
            // Simula o pressionamento das teclas juntamente com 'scaleEffect' aplicado
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                inputManager.setTrackpadPressed(false)
            }
        }
    }
    
    // Cada linha do teclado ANSI EUA tem o seguinte tamanho em pontos para um frame da janela 600 x 600
    // Linha 1: 13 * 20 (teclas normais) + 13 * 3 (espaços entre as teclas) + 1 * 20 * 1.6 (tecla esc)
    // Linha 2: 13 * 20 (teclas normais) + 13 * 3 (espaços entre as teclas) + 1 * 20 * 1.6 (tecla del)
    // Linha 3: 13 * 20 (teclas normais) + 13 * 3 (espaços entre as teclas) + 1 * 20 * 1.6 (tecla tab)
    // Linha 4: 11 * 20 (teclas normais) + 12 * 3 (espaços entre as teclas) + 2 * 20 * 1.9 (teclas caps e enter)
    // Linha 5: 10 * 20 (teclas normais) + 11 * 3 (espaços entre as teclas) + 2 * 20 * 2.5 (teclas shift)
    // Linha 6:  7 * 20 (teclas normais) +  9 * 3 (espaços entre as teclas) + 2 * 20 * 1.3 (teclas command) + 1 * 20 * 5.7 (tecla espaço)

    @ViewBuilder
    func keyRows(of keyboard: [[(Int, String)]], containerDimension geometry: GeometryProxy) -> some View {
        VStack(spacing: verticalSpaceBetweenKeys) {
            ForEach(keyboard.indices, id: \.self) { rowIndex in
                HStack(spacing: horizontalSpaceBetweenKeys) {
                    ForEach(keyboard[rowIndex], id: \.0) { key in
                        keyButton(key: key.1, viewDimension: geometry)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func keyButton(key: String, viewDimension geometry: GeometryProxy) -> some View {
        let keyWidthScaleFactor = inputManager.specialKeyWidths[key] ?? inputManager.standardKeyWidth

        Button {
        } label: {
            ZStack {
                // Fundo da tecla com baixo relevo
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.15))
                
                // Texto da tecla
                Text(keyLabel(for: key))
                    .font(.system(size: keyLabelSize))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: keyWidthScaleFactor * keyWidth, height: keyHeight)
            .scaleEffect(pressedKey == key ? 0.9 : 1.0)
            .animation(.spring(response: 0.1), value: pressedKey == key)
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: inputManager.pressedKeyCode) { _, pressedKeyCode in
            // Simula o pressionamento das teclas
            guard let pressedKeyCode else { return }

            self.pressedKey = inputManager.findKeyLabel(for: pressedKeyCode)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pressedKey = nil
                inputManager.setPressedKeyCodeValue(nil)
            }
        }
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
        case "shift l":
            return "⇧"
        case "shift r":
            return "⇧"
        case "fn":
            return "fn"
        case "control":
            return "⌃"
         case "option l":
            return "⌥"
       case "option r":
            return "⌥"
         case "command l":
            return "⌘"
       case "command r":
            return "⌘"
        case "":
            return ""  // Tecla de espaço - fica em branco
        case "←", "↑", "↓", "→":
            return key  // Teclas de seta
        case "esc":
            return "esc"
        default:
            return key
        }
    }
}
