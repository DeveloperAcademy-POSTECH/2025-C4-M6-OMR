//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//
import Domain
import SwiftUI

public extension Marker {
    static let mockMarkers: [Marker] = [
        Marker(
            id: UUID(),
            name: "장미",
            floriography: "사랑",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower1"
        ),
        Marker(
            id: UUID(),
            name: "튤립",
            floriography: "고백",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower1"
        ),
        Marker(
            id: UUID(),
            name: "해바라기",
            floriography: "존경",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower2"
        ),
        Marker(
            id: UUID(),
            name: "백합",
            floriography: "순수",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower2"
        ),
        Marker(
            id: UUID(),
            name: "수국",
            floriography: "변덕",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower1"
        ),
        Marker(
            id: UUID(),
            name: "무궁화",
            floriography: "영원",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower2"
        ),
        Marker(
            id: UUID(),
            name: "코스모스",
            floriography: "조화",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower1"
        ),
        Marker(
            id: UUID(),
            name: "데이지",
            floriography: "희망",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower2"
        ),
        Marker(
            id: UUID(),
            name: "프리지아",
            floriography: "우정",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower2"
        ),
        Marker(
            id: UUID(),
            name: "라벤더",
            floriography: "평온",
            emotionType: .all,
            thumbnailImageName: "cat",
            objectImageName: "flower1"
        )
    ]
}

