//
//  RecordList.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI

struct RecordList: View {
    let records: [MyRecordModel]
    let onRecordTap: (UUID) -> Void

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(records) { record in
                    Button(action: {
                        print("✅ Tapped Record:")
                         print("ID: \(record.id)")
                         print("Title: \(record.title)")
                         print("Date: \(record.formattedDate)")
                         print("Flower: \(record.flowerImageName)")
                         
                         onRecordTap(record.id)
                        onRecordTap(record.id)
                    }) {
                        RecordCard(record: record)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

