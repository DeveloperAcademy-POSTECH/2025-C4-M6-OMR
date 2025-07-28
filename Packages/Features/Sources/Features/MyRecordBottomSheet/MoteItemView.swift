//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/22/25.
//

import SwiftUI
import DesignSystem

struct MoteItemView: View {
    let mote: Mote

    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 66, height: 66)
                .background(
                    DesignSystemAssets.image(named: "\(mote.flower.objetImage)")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 66, height: 66)
                        .clipped()
                )
                .padding(.trailing,10)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(mote.title.isEmpty ? "제목 없음" : mote.title)")
                    .font(
                    Font.custom("Pretendard", size: 16)
                    .weight(.semibold)
                    )
                    .foregroundColor(DesignSystem.Color.Gray_black)

                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Text("\(formattedDate(from: mote.createdAt))")
                    .font(Font.custom("Pretendard", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(DesignSystem.Color.Gray_02)
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

