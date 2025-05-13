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
    private let keyboard = [
        [
            (53, "esc"), (1001, "F1"), (1002, "F2"), (160, "F3"), (177, "F4"),
            (176, "F5"), (178, "F6"),
            (1003, "F7"), (1004, "F8"), (1005, "F9"), (1006, "F10"),
            (1007, "F11"), (1008, "F12"), (1009, "on"),
        ],

        [
            (50, "`"), (18, "1"), (19, "2"), (20, "3"), (21, "4"), (23, "5"),
            (22, "6"),
            (26, "7"), (28, "8"), (25, "9"), (29, "0"), (27, "-"), (24, "="),
            (51, "delete"),
        ],

        [
            (48, "tab"), (12, "Q"), (13, "W"), (14, "E"), (15, "R"), (17, "T"),
            (16, "Y"),
            (32, "U"), (34, "I"), (31, "O"), (35, "P"), (33, "["), (30, "]"),
            (42, "\\"),
        ],

        [
            (1000, "caps"), (0, "A"), (1, "S"), (2, "D"), (3, "F"), (5, "G"),
            (4, "H"),
            (38, "J"), (40, "K"), (37, "L"), (41, ";"), (39, "'"),
            (36, "return"),
        ],

        [
            (56, "shift"), (6, "Z"), (7, "X"), (8, "C"), (9, "V"), (11, "B"),
            (45, "N"),
            (46, "M"), (43, ","), (47, "."), (44, "/"), (60, "shift"),
        ],

        [
            (63, "fn"), (59, "control"), (58, "option"), (55, "command"),
            (49, ""), (54, "command"), (61, "option"),
            (123, "←"), (125, "↑↓"), (124, "→"),
        ],

    ]

    /*    private let keyboard = [["esc", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "on"],
                            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "delete"],
                            ["tab", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\"],
                            ["caps", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "return"],
                            ["shift", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "shift"],
                            ["fn", "control", "option", "command", "", "command", "option", "←", "↑↓", "→"]]*/

    // Cada linha do teclado tem o seguinte tamanho em pontos para um frame da janela 600 x 600
    // Linha 1: 13 * 20 (teclas normais) + 13 * 3 (espaços entre as teclas) + 1 * 20 * 1.6 (tecla esc)
    // Linha 2: 13 * 20 (teclas normais) + 13 * 3 (espaços entre as teclas) + 1 * 20 * 1.6 (tecla del)
    // Linha 3: 13 * 20 (teclas normais) + 13 * 3 (espaços entre as teclas) + 1 * 20 * 1.6 (tecla tab)
    // Linha 4: 11 * 20 (teclas normais) + 12 * 3 (espaços entre as teclas) + 2 * 20 * 1.9 (teclas caps e enter)
    // Linha 5: 10 * 20 (teclas normais) + 11 * 3 (espaços entre as teclas) + 2 * 20 * 2.5 (teclas shift)
    // Linha 6:  7 * 20 (teclas normais) +  9 * 3 (espaços entre as teclas) + 2 * 20 * 1.3 (teclas command) + 1 * 20 * 5.7 (tecla espaço)

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

    private let standardKeyWidth: CGFloat = 1.0
    private let specialKeyWidths: [String: CGFloat] = [
        "esc": 1.6,
        "delete": 1.6,
        "tab": 1.6,
        "caps": 1.875,
        "return": 1.875,
        "shift": 2.45,
        "command": 1.3,
        "": 5.6,  // Barra de espaço
    ]

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
                    .frame(
                        width: keyboardBackgroundWidth,
                        height: keyboardBackgroundHeight)

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
        Button {
            self.trackpadPressed = true
            // Simula clique no trackpad
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.trackpadPressed = false
            }
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                .frame(width: trackpadWidth, height: trackpadHeight)
                .scaleEffect(trackpadPressed ? 0.995 : 1.0)
                .animation(.spring(response: 0.1), value: trackpadPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }

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
        let keyWidthScaleFactor = specialKeyWidths[key] ?? standardKeyWidth

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
                    .font(.system(size: keyLabelSize))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: keyWidthScaleFactor * keyWidth, height: keyHeight)
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
            return key  // Teclas de seta
        case "esc":
            return "esc"
        default:
            return key
        }
    }
}
