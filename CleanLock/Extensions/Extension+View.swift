//
//  Extension+View.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 15/05/25.
//

import SwiftUI

extension View {
    func customViewStyle(viewDimension size: CGSize) -> some View {
        self
            .frame(width: size.width * 0.95, height: size.height * 0.4725)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)
    }
}
