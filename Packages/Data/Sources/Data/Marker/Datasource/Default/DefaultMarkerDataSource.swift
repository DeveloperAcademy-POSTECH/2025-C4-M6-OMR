//
//  DefaultMarkerDataSource.swift
//  Data
//
//  Created by eunsong on 7/28/25.
//
import Foundation

public struct DefaultMarkerDataSource: Sendable {

    public init() {}

    public func getRawMarkers() -> [RawMarkerData] {
        return [
            RawMarkerData(
                id: UUID(),
                displayName: "버터컵",
                floriography: "순수한 마음, 매력",
                imageName: "YellowFlower"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "화이트 데이지",
                floriography: "천진난만, 희망",
                imageName: "WhiteFlower"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "핑크 데이지",
                floriography: "사랑스러움",
                imageName: "PinkFlower"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "바이올렛",
                floriography: "겸손, 신중함",
                imageName: "Violet"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "튤립",
                floriography: "영원한 사랑",
                imageName: "Tulip"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "스위트 피",
                floriography: "즐거운 추억",
                imageName: "SweetPea"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "금어초",
                floriography: "설렘",
                imageName: "Snapdragon"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "장미",
                floriography: "사랑, 열정",
                imageName: "Rose"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "팬지",
                floriography: "나를 생각해 주세요",
                imageName: "Pansy"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "난초",
                floriography: "아름다움, 세련됨",
                imageName: "Orchid"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "라벤더",
                floriography: "기다림, 평화",
                imageName: "Lavender"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "자스민",
                floriography: "영원한 행복",
                imageName: "Jasmine"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "붓꽃",
                floriography: "기쁜 소식",
                imageName: "Iris"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "글라디올러스",
                floriography: "성실, 용기",
                imageName: "Gladiolus"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "수선화",
                floriography: "새로운 시작",
                imageName: "Daffodil"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "코스모스",
                floriography: "조화, 평화",
                imageName: "Cosmos"
            ),
            RawMarkerData(
                id: UUID(),
                displayName: "아네모네",
                floriography: "기다림",
                imageName: "Anemone"
            )
        ]
    }
}
