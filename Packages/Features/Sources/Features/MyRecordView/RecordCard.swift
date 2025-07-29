//
//  RecordCard.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI
import DesignSystem

struct RecordCard: View {
    let record: MyRecordModel
    
    var body: some View {
        HStack(spacing: 10) {
            DesignSystemAssets.image(named: record.flowerImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 66, height: 66)
                .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(record.title)
                    .font(DesignSystem.Font.Title3.semibold)
                    .foregroundColor(DesignSystem.Color.Gray_black)
                    .lineLimit(1)
                
                Text(record.formattedDate)
                    .font(DesignSystem.Font.Headline.medium)
                    .foregroundColor(DesignSystem.Color.Gray_02)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        
    }
}

#Preview {
    RecordCard(
        record: MyRecordModel.createMock().first!
    )
    .padding()
}
