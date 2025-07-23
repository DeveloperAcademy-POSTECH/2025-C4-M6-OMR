//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/22/25.
//

import SwiftUI

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
                    .foregroundColor(Color(red: 0.2, green: 0.24, blue: 0.3))
                    .opacity(0.6)

                Spacer()

                Text("\(totalCount)")
                    .font(
                        Font.custom("Pretendard", size: 16)
                            .weight(.bold)
                    )
                    .foregroundColor(Color(red: 0.43, green: 0.65, blue: 0.96))

                Image(systemName: "chevron.right")
                    .font(
                        Font.custom("Pretendard", size: 14)
                            .weight(.semibold)
                    )
                    .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
                    .opacity(0.15)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.94, green: 0.96, blue: 1))
            .cornerRadius(16)
        }
        .padding(.bottom, 36)
    }
}
