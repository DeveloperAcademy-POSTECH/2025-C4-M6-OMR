//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//
import SwiftUI

public extension FlowerModel {
    static func FlowerObjects() -> [FlowerModel] {
        let flower1 = FlowerModel(
            id: UUID(),
            name: "장미",
            floriography: "사랑",
            thumbnailImageName: "cat",
            objectImageName: "flower1",
            thumbnailLarge: ""
        )
        
        let flower2 = FlowerModel(
            id: UUID(),
            name: "튤립",
            floriography: "고백",
            thumbnailImageName: "cat",
            objectImageName: "flower1",
            thumbnailLarge: ""
        )
        let flower3 = FlowerModel(
            id: UUID(),
            name: "해바라기",
            floriography: "존경",
            thumbnailImageName: "cat",
            objectImageName: "flower2",
            thumbnailLarge: ""
        )
        let flower4 = FlowerModel(
            id: UUID(),
            name: "백합",
            floriography: "순수",
            thumbnailImageName: "cat",
            objectImageName: "flower2",
            thumbnailLarge: ""
        )
        let flower5 = FlowerModel(
            id: UUID(),
            name: "수국",
            floriography: "변덕",
            thumbnailImageName: "cat",
            objectImageName: "flower1",
            thumbnailLarge: ""
        )
        let flower6 = FlowerModel(
            id: UUID(),
            name: "무궁화",
            floriography: "영원",
            thumbnailImageName: "cat",
            objectImageName: "flower2",
            thumbnailLarge: ""
        )
        return [flower1, flower2, flower3, flower4, flower5, flower6]
    }
}

