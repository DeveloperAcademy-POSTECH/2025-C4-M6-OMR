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
            objetImage: "flower1"
        )

        let flower2 = EmotionObject(
            name: "해바라기",
            floriography: "희망",
            emotionType: .happiness,
            thumbnail: "sunflower_thumb.png",
            objetImage: "flower1"
        )

        let flower3 = EmotionObject(
            name: "백합",
            floriography: "순수",
            emotionType: .love,
            thumbnail: "lily_thumb.png",
            objetImage: "flower2"
        )

        let flower4 = EmotionObject(
            name: "수국",
            floriography: "변화",
            emotionType: .sadness,
            thumbnail: "hydrangea_thumb.png",
            objetImage: "flower2"
        )

        let baseDate = Date()

        return [
            // 기존 포항 북구 양덕동
            Mote(
                userId: UUID(),
                title: "첫 번째 기록",
                images: ["img1.jpg", "img2.jpg"],
                createdAt: baseDate,
                latitude: 36.0427,
                longitude: 129.3589,
                address: "경상북도 포항시",
                flower: flower1,
                isPublic: true
            ),
            Mote(
                userId: UUID(),
                title: "두 번째 기록",
                images: ["img3.jpg"],
                createdAt: baseDate.addingTimeInterval(-86400),
                latitude: 36.0425,
                longitude: 129.3591,
                address: "경상북도 포항시",
                flower: flower2,
                isPublic: false
            ),

            // 포스텍 청암로 77 근처 오브제
            Mote(
                userId: UUID(),
                title: "포스텍 정문 앞 장미",
                images: ["rose1.jpg"],
                createdAt: baseDate.addingTimeInterval(-3600),
                latitude: 36.0135,
                longitude: 129.3235,
                address: "경상북도 포항시 남구 청암로 77 포스텍 정문 앞",
                flower: flower1,
                isPublic: true
            ),
            Mote(
                userId: UUID(),
                title: "수국이 피어난 과학관 뒤",
                images: ["hydrangea1.jpg"],
                createdAt: baseDate.addingTimeInterval(-7200),
                latitude: 36.0138,
                longitude: 129.3242,
                address: "경상북도 포항시 남구 청암로 77 과학관 뒤편",
                flower: flower4,
                isPublic: true
            ),
            Mote(
                userId: UUID(),
                title: "백합이 있는 중앙도서관 옆",
                images: ["lily1.jpg"],
                createdAt: baseDate.addingTimeInterval(-10800),
                latitude: 36.0142,
                longitude: 129.3228,
                address: "경상북도 포항시 남구 청암로 77 중앙도서관 옆",
                flower: flower3,
                isPublic: false
            ),
            Mote(
                userId: UUID(),
                title: "햇살 가득한 학생회관 앞 해바라기",
                images: ["sunflower1.jpg"],
                createdAt: baseDate.addingTimeInterval(-14400),
                latitude: 36.0140,
                longitude: 129.3239,
                address: "경상북도 포항시 남구 청암로 77 학생회관 앞",
                flower: flower2,
                isPublic: true
            )
        ]
    }

}
