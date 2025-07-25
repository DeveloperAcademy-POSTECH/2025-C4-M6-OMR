//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import Foundation
import SwiftUI

@MainActor
final class FlowerSelectionViewModel: ObservableObject {
    @Published var flowers: [FlowerModel] = []
    @Published var selectedFlower: FlowerModel?
    
    public var onFlowerSelected: ((UUID) -> Void)?
    
    init() {
        loadMockFlowers()
    }
    
    private func loadMockFlowers() {
        // 미리 정의된 mockFlowers를 불러옴
        self.flowers = FlowerModel.FlowerObjects()
    }
    
    
    func selectFlower(_ flower: FlowerModel) {
        selectedFlower = flower
        onFlowerSelected?(flower.id)
        print("선택된 꽃: \(flower.name)")
    }
}
