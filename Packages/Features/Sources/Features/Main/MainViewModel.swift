import Combine
import Dependencies
import Domain
import Foundation

@MainActor
public final class MainViewModel: ObservableObject {
    // MARK: - State
    @Published public var totalCount: Int = 0
    @Published public var nearbyCount: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    // MARK: - Dependencies
    @Dependency(\.fetchMyRecordsUseCase) private var fetchMyRecordsUseCase

    public init() {}

    // MARK: - Public Methods
    public func loadNearbyMotesMock(center: Location, radius: Double) {
        isLoading = true
        errorMessage = nil

        Task {
            let allMotes = MockDataProvider.mockObjects()
            self.totalCount = allMotes.count
            
            // 🌸 전체 꽃 이름 출력
            print("🌸 전체 꽃 목록:")
            for mote in allMotes {
                print("- \(mote.title)")
            }

            let nearby = allMotes.filter { mote in
                let distance = haversineDistance(
                    lat1: center.latitude,
                    lon1: center.longitude,
                    lat2: mote.latitude,
                    lon2: mote.longitude
                )
                return distance <= radius
            }

            self.nearbyCount = nearby.count
            self.isLoading = false
            
            // ✅ 전체 개수 출력
            print("🌸 전체 꽃 개수: \(self.totalCount)")
            print("🌸 근처 꽃 개수: \(self.nearbyCount)")
        }
    }


    // Haversine 거리 계산 (미터 단위)
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0 // 지구 반지름 (m)
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
