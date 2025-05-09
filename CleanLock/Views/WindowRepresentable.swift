//
//  WindowAccessor.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 05/05/25.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
