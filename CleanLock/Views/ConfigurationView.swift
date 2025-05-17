//
//  MainView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 05/05/25.
//

import SwiftUI

struct ConfigurationView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject private var inputManager: InputBlockingManager
    
    @Binding var path: [Route]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Configurações")
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Divider()
            
            keyboardIconView()
            
            Divider()
                .padding(.horizontal)
            
            trackpadIconView()
            
            Divider()
                .padding(.horizontal)
            
            cleanButtonView(path: $path)
            
            Divider()
            
            HStack {
                Spacer()
                
                Text("Para destravar o teclado e o trackpad, pressione as duas teclas Shift simultaneamente")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.top, 30)
        }
    }
}

struct keyboardIconView: View {
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

struct trackpadIconView: View {
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
    @EnvironmentObject private var contentViewModel: ContentViewModel
    @EnvironmentObject private var inputManager: InputBlockingManager
    @Binding var path: [Route]

    var body: some View {
        HStack {
            Spacer()
            
            Button {
                path.append(.keyboardView)
                inputManager.startCleaning()
            } label: {
                Label("Iniciar Limpeza", systemImage: "drop.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .disabled(!inputManager.isKeyboardLocked && !inputManager.isTrackpadLocked)
        .disabled(inputManager.isCleaning)
    }
}
