//
//  KeyboardKeyView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 10/05/25.
//

import SwiftUI

struct KeyboardView: View {
    @EnvironmentObject private var contentViewModel: ContentViewModel
    @EnvironmentObject private var inputManager: InputBlockingManager
    @State private var horizontalSpaceBetweenKeys: CGFloat = .zero
    @State private var verticalSpaceBetweenKeys: CGFloat = .zero
    @State private var keyboardBackgroundWidth: CGFloat = .zero
    @State private var keyboardBackgroundHeight: CGFloat = .zero
    @State private var trackpadWidth: CGFloat = .zero
    @State private var trackpadHeight: CGFloat = .zero
    @State private var keyWidth: CGFloat = .zero
    @State private var keyHeight: CGFloat = .zero
    @State private var keyLabelSize: CGFloat = .zero
    @State private var pressedKey: Int64? = nil
    
    @Binding var path: [Route]
    
    var body: some View {
        GeometryReader { geometry in
            // Atualiza as medidas relativas utilizadas nas views
            let _ = updateDimensions(viewDimension: geometry.size)
            
            VStack {
                VStack {
                    keyboard(with: inputManager.keys)
                    
                    trackpadView()
                }
                .customViewStyle(viewDimension: geometry.size)
                
                Divider()
                    .padding(.horizontal)
                
                CleaningView()
                    .customViewStyle(viewDimension: geometry.size)
            }
        }
        .opacity(contentViewModel.keyboardViewOpacity)
        .navigationBarBackButtonHidden(true)
        .onChange(of: inputManager.areBothShiftKeysPressed) { _, pressed in
            if pressed {
                inputManager.stopCleaning()
                path.removeAll()
            }
        }
    }
    
    
    @ViewBuilder
    func trackpadView() -> some View {
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
    func keyboard(with keys: [[(Int64, String)]]) -> some View {
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
            
            // Teclas do teclado
            VStack(spacing: verticalSpaceBetweenKeys) {
                ForEach(keys.indices, id: \.self) { rowIndex in
                    HStack(spacing: horizontalSpaceBetweenKeys) {
                        ForEach(keys[rowIndex], id: \.0) { key in
                            keyButton(keyCode: key.0)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func keyButton(keyCode: Int64) -> some View {
        let keyString = inputManager.findKeyLabel(for: keyCode)!
        let keyWidthScaleFactor = inputManager.specialKeyWidths[keyString] ?? inputManager.standardKeyWidth

        Button {
        } label: {
            ZStack {
                // Fundo da tecla com baixo relevo
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.15))
                
                // Texto da tecla
                Text(keyLabel(for: keyString))
                    .font(.system(size: keyLabelSize))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: keyWidthScaleFactor * keyWidth, height: keyHeight)
            .scaleEffect(pressedKey == keyCode ? 0.9 : 1.0)
            .animation(.spring(response: 0.1), value: pressedKey == keyCode)
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: inputManager.pressedKeyCode) { _, pressedKeyCode in
            // Simula o pressionamento das teclas
            guard let pressedKeyCode else { return }

            self.pressedKey = pressedKeyCode
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pressedKey = nil
                inputManager.setPressedKeyCodeValue(nil)
            }
        }
    }
    
    private func updateDimensions(viewDimension size: CGSize) {
        DispatchQueue.main.async {
            horizontalSpaceBetweenKeys = size.width / 200
            verticalSpaceBetweenKeys = size.height / 200
            keyboardBackgroundWidth = size.width / 1.75
            keyboardBackgroundHeight = size.height / 4.1075
            trackpadWidth = size.width / 4
            trackpadHeight = size.height / 6.6667
            keyWidth = size.width / 30
            keyHeight = size.height / 30
            keyLabelSize = size.width / 82.475
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
