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
    @Published var markers: [FlowerModel] = []
    @Published var selectedMarker: FlowerModel?
    
    init() {
        loadMockMarkers()
    }
    
    private func loadMockMarkers() {
        // 미리 정의된 mockMarkers를 불러옴
        self.markers = FlowerModel.FlowerObjects()
    }
    
    
    func selectMarker(_ marker: FlowerModel) {
        selectedMarker = marker
        print("선택된 꽃: \(marker.name)")
    }
}
