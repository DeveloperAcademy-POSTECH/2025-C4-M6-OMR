//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/25/25.
//

import Foundation

struct MyRecordModel: Identifiable {
    let id: UUID
    let title: String
    let createdAt: Date
    let flowerImageName: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 dd일"
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Mock Creator
    static func createMock() -> [MyRecordModel] {
        return MockDataProvider.mockObjects().map { mote in
            MyRecordModel(
                id: mote.id,
                title: mote.title,
                createdAt: mote.createdAt,
                flowerImageName: mote.flower.objetImage
            )
        }
    }
}

import Foundation

final class MyRecordViewModel: ObservableObject {
    @Published var records: [MyRecordModel] = []
    
    init() {
           loadMockRecords()
       }
       
       private func loadMockRecords() {
           self.records = MyRecordModel.createMock()
               .sorted(by: { $0.createdAt > $1.createdAt }) // 최신순 정렬
           
           for record in records {
                   print("🔹 Record ID: \(record.id)")
                   print("   Title: \(record.title)")
                   print("   Created At: \(record.formattedDate)")
                   print("   Flower Image Name: \(record.flowerImageName)")
               }

       }
}


