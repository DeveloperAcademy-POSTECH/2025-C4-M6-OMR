//
//  RecordCard.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI

struct RecordCard: View {
    let record: ObjectEntity
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: record.createdAt)
    }
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 66, height: 66)

                Image(record.flower.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 66, height: 66)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(record.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)

    }
}

#Preview {
    RecordCard(
        record: MockDataManager.shared.mockRecords.first!
    )
    .padding()
}
