import Combine
import Dependencies
import Domain
import Foundation

@MainActor
public final class MainViewModel: ObservableObject {
    // MARK: - State
    @Published public var motes: [MainMote] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    // MARK: - Dependencies
    // Domain에 정의된 DependencyKey를 통해 실제 구현체를 주입받습니다.
    @Dependency(\.fetchNearbyMotesUseCase) private var fetchNearbyMotesUseCase
    
    public init() {}
    
    // MARK: - Public Methods
    public func loadNearbyMotesMock(center: Location, radius: Double) {
        isLoading = true
        errorMessage = nil
        
        Task {
            let allMotes = MockDataProvider.mockObjects()
            let filtered = allMotes.filter { mote in
                let distance = haversineDistance(
                    lat1: center.latitude,
                    lon1: center.longitude,
                    lat2: mote.latitude,
                    lon2: mote.longitude
                )
                print("mote: \(mote.title), distance: \(distance) meters")
                return distance <= radius
            }
            
            self.motes = filtered.map {
                MainMote(id: $0.id, latitude: $0.latitude, longitude: $0.longitude)
            }
            
            self.isLoading = false
        }
    }
    
    
    
    // Haversine 거리 계산 (미터 단위)
    private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0 // 지구 반지름 (m)
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
        cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
        sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
    
}
