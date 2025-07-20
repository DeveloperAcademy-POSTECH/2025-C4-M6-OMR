//
//  MyRecordView.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI

struct MyRecordView: View {
    @State private var records: [ObjectEntity] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Text("전체")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                // 20포인트 간격
                Spacer()
                    .frame(height: 20)
                
                RecordList(records: records)
                    .onAppear {
                        loadMockData()
                    }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func loadMockData() {
        records = MockDataManager.shared.sortedRecords
    }
}

#Preview {
    MyRecordView()
}
