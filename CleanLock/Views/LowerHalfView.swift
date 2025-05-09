//
//  MainView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 05/05/25.
//

import SwiftUI

struct LowerHalfView: View {
    @EnvironmentObject var contentViewController: ContentViewController
    @EnvironmentObject private var inputManager: InputBlockingManager
    @State private var opacity = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.1))
                    
                    VStack(alignment: .leading) {
                        Text("Configurações")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        keyboardBlockView()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        trackpadBlockView()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        cleanButtonView()
                    }
                }
                .frame(height: geometry.size.height * 0.80)
                .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Text("Para destravar o teclado e o trackpad, pressione as duas teclas Shift simultaneamente.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(height: geometry.size.height * 0.1)
                .padding([.horizontal, .bottom])
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct keyboardBlockView: View {
    @EnvironmentObject private var inputManager: InputBlockingManager
    
    var body: some View {
        HStack {
             ProminentRoundedRectangle(color: Color.customAccentColor)
                 .frame(width: 25, height: 25)
                 .overlay(Image(systemName: "keyboard")
                     .foregroundStyle(Color.white)
                     .controlSize(.small))
             
             Text("Bloquear Teclado")
             
             Spacer()
             
             Toggle("", isOn: $inputManager.isKeyboardLocked)
                 .toggleStyle(.switch)
                 .controlSize(.mini)
         }
         .padding(.horizontal)
    }
}

struct trackpadBlockView: View {
    @EnvironmentObject private var inputManager: InputBlockingManager
    
    var body: some View {
        HStack {
            ProminentRoundedRectangle(color: Color.customAccentColor)
                .frame(width: 25, height: 25)
                .overlay(Image(systemName: "rectangle.and.hand.point.up.left")
                    .foregroundStyle(Color.white)
                    .controlSize(.small))
            
            Text("Bloquear Trackpad")
            
            Spacer()
            
            Toggle("", isOn: $inputManager.isTrackpadLocked)
                .toggleStyle(.switch)
                .controlSize(.mini)
        }
        .padding(.horizontal)
    }
}

struct cleanButtonView: View {
    @EnvironmentObject private var contentViewController: ContentViewController
    @EnvironmentObject private var inputManager: InputBlockingManager

    var body: some View {
        HStack {
            Spacer()
            
            Button {
                inputManager.startCleaning()
            } label: {
                Label("Iniciar Limpeza", systemImage: "drop.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .disabled(!contentViewController.hasAccessibilityPermission)
        .disabled(!inputManager.isKeyboardLocked && !inputManager.isTrackpadLocked)
        .disabled(inputManager.isCleaning)
    }
}

#Preview {
    LowerHalfView()
        .tint(Color.customAccentColor)
        .environmentObject(ContentViewController())
        .environmentObject(InputBlockingManager())
}
