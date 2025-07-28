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
                name: "장미",
                floriography: "사랑",
                thumbnailImageName: "YellowFlower_M.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "튤립",
                floriography: "설렘",
                thumbnailImageName: "YellowFlower_L.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "프리지아",
                floriography: "우정",
                thumbnailImageName: "YellowFlower_M.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "클로버",
                floriography: "행운",
                thumbnailImageName: "YellowFlower_L.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "라벤더",
                floriography: "평온",
                thumbnailImageName: "YellowFlower_M.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "코스모스",
                floriography: "조화",
                thumbnailImageName: "YellowFlower_L.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "백합",
                floriography: "위로",
                thumbnailImageName: "YellowFlower_M.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "파란 수국",
                floriography: "냉정",
                thumbnailImageName: "YellowFlower_L.png",
                objectImageName: "test_flower"
            ),
            RawMarkerData(
                id: UUID(),
                name: "히아신스",
                floriography: "슬픔",
                thumbnailImageName: "YellowFlower_M.png",
                objectImageName: "test_flower"
            ),
        ]
    }
}
