//
//  ContentViewController.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 09/05/25.
//

import SwiftUI
import Cocoa
import Combine

class ContentViewModel: ObservableObject {
    @Published private(set) var contentViewOpacity = 1.0
    @Published private(set) var keyboardViewOpacity = 0.0
    
    func setContentViewOpacity(_ opacity: CGFloat) {
        withAnimation {
            contentViewOpacity = opacity
        }
    }
    
    func setKeyboardViewOpacity(_ opacity: CGFloat) {
        withAnimation {
            keyboardViewOpacity = opacity
        }
    }
}
