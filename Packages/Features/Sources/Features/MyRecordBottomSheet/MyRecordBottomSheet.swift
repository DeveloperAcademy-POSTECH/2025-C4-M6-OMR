//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//

import SwiftUI

struct MyRecordBottomSheet: View {
    @Binding var sheetPosition: SheetPosition  // 👈 Binding으로 변경
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                if sheetPosition == .half {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 40, height: 5)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.top, 8)
                } else {
                    // full 모드일 때 top padding 확보
                    Spacer().frame(height: 16)
                }
                
                // Bottom sheet content
                Text("내 기록 내용 등...")
                    .frame(maxWidth: .infinity)
                
                Spacer()
            }
            
            // 👇 X 버튼 (full 상태일 때만 표시)
            if sheetPosition == .full {
                Button(action: {
                    sheetPosition = .half
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(Color(.systemGray5).opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(sheetPosition == .full ? 0 : 16)
        .shadow(radius: sheetPosition == .full ? 0 : 10)
    }
}




