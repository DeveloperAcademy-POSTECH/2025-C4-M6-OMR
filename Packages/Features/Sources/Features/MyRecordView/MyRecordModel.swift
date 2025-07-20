//
//  MyRecordModel.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import Foundation
import SwiftData

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

@Model
final class ObjectEntity {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var title: String
    var createdAt: Date
    var latitude: Double
    var longitude: Double
    var address: String
    var flower: Flower
    
    init(id: UUID = UUID(), userId: UUID, title: String, createdAt: Date, latitude: Double, longitude: Double, address: String, flower: Flower) {
        self.id = id
        self.userId = userId
        self.title = title
        self.createdAt = createdAt
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.flower = flower
    }
}

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

@MainActor
class MockDataManager {
    static let shared = MockDataManager()
    
    private init() {}
    
    // Mock User
    let mockUser = User(
        name: "testUser"
    )
    
    // Mock ObjectEntity Data
    lazy var mockRecords: [ObjectEntity] = [
        ObjectEntity(
            userId: mockUser.id,
            title: "포항공과대학교에서",
            createdAt: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 12))!,
            latitude: 36.0129,
            longitude: 129.3252,
            address: "경북 포항시 남구 청암로 77",
            flower: .tulip
        ),
        ObjectEntity(
            userId: mockUser.id,
            title: "영일대에서 애들이랑",
            createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
            latitude: 36.4151,
            longitude: 129.3665,
            address: "경북 영덕군 영덕읍 대학로 1",
            flower: .sunflower
        ),
        ObjectEntity(
            userId: mockUser.id,
            title: "C5 세션이 끝난 뒤",
            createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
            latitude: 36.4151,
            longitude: 129.3665,
            address: "경북 포항시 남구 청암로 77",
            flower: .sunflower
        ),
        ObjectEntity(
            userId: mockUser.id,
            title: "C5 세션이 끝난 뒤",
            createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
            latitude: 36.4151,
            longitude: 129.3665,
            address: "경북 포항시 남구 청암로 77",
            flower: .sunflower
        ),
        ObjectEntity(
            userId: mockUser.id,
            title: "C5 세션이 끝난 뒤",
            createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 7))!,
            latitude: 36.4151,
            longitude: 129.3665,
            address: "경북 포항시 남구 청암로 77",
            flower: .sunflower
        )

    ]
    
    // 날짜순 오름차순 정렬된 데이터 반환
    var sortedRecords: [ObjectEntity] {
        return mockRecords.sorted { $0.createdAt < $1.createdAt }
    }
}
