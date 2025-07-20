//
//  RecordList.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI

struct RecordList: View {
    let records: [ObjectEntity]
    
    var body: some View {
        ScrollView {
            LazyVStack() {
                ForEach(records, id: \.id) { record in
                    RecordCard(record: record)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    RecordList(
        records: MockDataManager.shared.sortedRecords
    )
}
