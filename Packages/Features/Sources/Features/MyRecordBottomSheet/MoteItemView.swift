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
                Text("\(mote.title.isEmpty ? "\(mote.address)에서" : mote.title)")
                    .font(DesignSystem.Font.Title3.semibold)
                    .foregroundColor(DesignSystem.Color.Gray_black)

                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Text("\(formattedDate(from: mote.createdAt))")
                    .font(DesignSystem.Font.Headline.regular)
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

