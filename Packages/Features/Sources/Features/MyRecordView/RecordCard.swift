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
        HStack(spacing: 16) {
            DesignSystemAssets.image(named: record.flowerImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
