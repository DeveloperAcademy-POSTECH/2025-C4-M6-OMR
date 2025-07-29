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
                    .font(DesignSystem.Font.Title3.medium)
                    .foregroundColor(DesignSystem.Color.Gray_04)
                    .opacity(0.6)

                Spacer()

                Text("\(totalCount)")
                    .font(DesignSystem.Font.Title3.bold)
                    .foregroundColor(DesignSystem.Color.Prime2)

                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.Headline.semibold)
                    .foregroundColor(DesignSystem.Color.Gray_black)
                    .opacity(0.15)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Color.Gray_01)
            .cornerRadius(16)
        }
        .padding(.bottom, 16)
    }
}
