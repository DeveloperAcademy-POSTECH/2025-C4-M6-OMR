import Foundation
import Combine
import CoreLocation
import SwiftUI

@MainActor
final class MyRecordBottomSheetViewModel: ObservableObject {
    @Published var allMotes: [Mote] = []
    @Published var filteredMotes: [Mote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadAllMotes() {
        isLoading = true
        errorMessage = nil

        Task {
            self.allMotes = MockDataProvider.mockObjects()
            self.filteredMotes = allMotes
            isLoading = false
        }
    }

    func filterMotesByLocation(currentLocation: CLLocation, radiusInMeters: Double = 1000) {
        isLoading = true
        errorMessage = nil

        Task {
            let filtered = allMotes.filter { mote in
                let moteLocation = CLLocation(latitude: mote.latitude, longitude: mote.longitude)
                let distance = currentLocation.distance(from: moteLocation)
                return distance <= radiusInMeters
            }

            self.filteredMotes = filtered
            isLoading = false
        }
    }
}

