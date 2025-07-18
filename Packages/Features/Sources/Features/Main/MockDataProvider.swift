//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//
import Dependencies
import Foundation
import FileProvider


struct MockDataProvider {
    static func mockObjects() -> [Mote] {
        let flower1 = EmotionObject(
            name: "장미",
            floriography: "사랑",
            emotionType: .love,
            thumbnail: "rose_thumb.png",
            objetImage: "rose_object.png"
        )
        
        let flower2 = EmotionObject(
            name: "해바라기",
            floriography: "희망",
            emotionType: .happiness,
            thumbnail: "sunflower_thumb.png",
            objetImage: "sunflower_object.png"
        )
        
        let object1 = Mote(
            userId: UUID(),
            title: "첫 번째 기록",
            images: ["img1.jpg", "img2.jpg"],
            createdAt: Date(),
            latitude: 36.0427,          // 포항시 양덕동 대략 위도
            longitude: 129.3589,        // 포항시 양덕동 대략 경도
            address: "경상북도 포항시 북구 양덕동 1234-5 스타벅스",
            flower: flower1,
            isPublic: true
        )
        
        let object2 = Mote(
            userId: UUID(),
            title: "두 번째 기록",
            images: ["img3.jpg"],
            createdAt: Date().addingTimeInterval(-86400), // 하루 전
            latitude: 36.0425,          // 약간 근처 위도
            longitude: 129.3591,        // 약간 근처 경도
            address: "경상북도 포항시 북구 양덕동 1234-7 근처",
            flower: flower2,
            isPublic: false
        )
        
        
        return [object1, object2]
    }
}
