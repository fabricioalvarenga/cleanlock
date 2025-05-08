//
//  UpperHalfView.swift
//  Cleanup Keyboard
//
//  Created by FABRICIO ALVARENGA on 06/05/25.
//

import SwiftUI

struct UpperHalfView: View {
    var body: some View {
        VStack {
            Image(systemName: "macbook")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom)
            
            Text("Limpe o seu Macbook")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Bloqueie o teclado e o trackpad antes de realizar a limpeza")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .padding(.horizontal)
        
    }
}

#Preview {
    UpperHalfView()
}
