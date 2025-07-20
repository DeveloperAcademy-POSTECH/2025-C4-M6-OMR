//
//  RecordCard.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI

struct RecordCard: View {
    let record: MyRecordModel
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 66, height: 66)

                Image(record.flowerImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 66, height: 66)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(record.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(record.formattedDate)
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
        record: MyRecordModel.createMock().first!
    )
    .padding()
}
