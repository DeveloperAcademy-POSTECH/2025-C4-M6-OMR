//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//

import SwiftUI

struct MyRecordBottomSheet: View {
    let sheetPosition: SheetPosition
    
    var body: some View {
        VStack(spacing: 8) {
            if sheetPosition == .half {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 40, height: 5)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.top, 8)
            }
            
            // Bottom sheet content
            Text("내 기록 내용 등...")
                .frame(maxWidth: .infinity) 
            
            Spacer()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(sheetPosition == .full ? 0 : 16) // fullscreen일 땐 모서리 둥글기 없앰
        .shadow(radius: sheetPosition == .full ? 0 : 10)
    }
}



