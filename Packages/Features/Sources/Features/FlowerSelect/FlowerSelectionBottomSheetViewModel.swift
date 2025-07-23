//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import Foundation
import SwiftUI
import Domain

@MainActor
final class FlowerSelectionViewModel: ObservableObject {
    @Published var markers: [Marker] = []
    @Published var selectedMarker: Marker?

    init() {
        loadMockMarkers()
    }

    private func loadMockMarkers() {
        // 미리 정의된 mockMarkers를 불러옴
        self.markers = Marker.mockMarkers
    }

    func selectMarker(_ marker: Marker) {
        selectedMarker = marker
        print("선택된 꽃: \(marker.name)")
    }
}
