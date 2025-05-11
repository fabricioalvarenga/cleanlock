//
//  TitleView.swift
//  CleanLock
//
//  Created by FABRICIO ALVARENGA on 06/05/25.
//

import SwiftUI

struct TitleView: View {
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
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
}

#Preview {
    TitleView()
}
