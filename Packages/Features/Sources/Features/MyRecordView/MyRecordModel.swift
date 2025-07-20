//
//  MyRecordModel.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import Foundation
import Combine

enum Flower: String, CaseIterable, Codable {
    case tulip = "tulip"
    case sunflower = "sunflower"
    
    var displayName: String {
        switch self {
        case .tulip: return "튤립"
        case .sunflower: return "해바라기"
        }
    }
    
    var imageName: String {
        switch self {
        case .tulip: return "flower1"
        case .sunflower: return "flower2"
        }
    }
}

struct MyRecordModel: Identifiable {
    let id: UUID
    let title: String
    let formattedDate: String
    let flowerImageName: String
}

extension MyRecordModel {
    static func createMock() -> [MyRecordModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        
        let mockData = [
            (
                title: "포항공과대학교에서",
                date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 12))!,
                flower: Flower.tulip
            ),
            (
                title: "영일대에서 애들이랑",
                date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
                flower: Flower.sunflower
            ),
            (
                title: "C5 세션이 끝난 뒤",
                date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
                flower: Flower.sunflower
            ),
            (
                title: "C5 세션이 끝난 뒤",
                date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
                flower: Flower.sunflower
            ),
            (
                title: "C5 세션이 끝난 뒤",
                date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
                flower: Flower.sunflower
            )
        ]
        
        return mockData.map { data in
            MyRecordModel(
                id: UUID(),
                title: data.title,
                formattedDate: dateFormatter.string(from: data.date),
                flowerImageName: data.flower.imageName
            )
        }.sorted { first, second in
            let firstDate = mockData.first { $0.title == first.title }?.date ?? Date()
            let secondDate = mockData.first { $0.title == second.title }?.date ?? Date()
            return firstDate < secondDate
        }
    }
}

@MainActor
final class MyRecordViewModel: ObservableObject {
    @Published var records: [MyRecordModel] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        records = MyRecordModel.createMock()
    }
}
