//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/22/25.
//

import SwiftUI
import DesignSystem

struct AllRecordButtonView: View {
    let totalCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("전체")
                    .font(
                        Font.custom("Pretendard", size: 16)
                            .weight(.medium)
                    )
                    .foregroundColor(DesignSystem.Color.Gray_01)
                    .opacity(0.6)

                Spacer()

                Text("\(totalCount)")
                    .font(
                        Font.custom("Pretendard", size: 16)
                            .weight(.bold)
                    )
                    .foregroundColor(DesignSystem.Color.Prime2)

                Image(systemName: "chevron.right")
                    .font(
                        Font.custom("Pretendard", size: 14)
                            .weight(.semibold)
                    )
                    .foregroundColor(DesignSystem.Color.Gray_black)
                    .opacity(0.15)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Color.Gray_01)
            .cornerRadius(16)
        }
        .padding(.bottom, 36)
    }
}
