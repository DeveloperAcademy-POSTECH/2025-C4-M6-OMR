import Foundation
import CoreLocation
import Domain
import Combine

@MainActor
final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Properties
    @Published var objectSummaries: [ObjectSummary] = []
    @Published var selectObjectDetail: ObjectSummary? = nil
    @Published var cameraPosition: CLLocationCoordinate2D? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let locationManager = CLLocationManager()
    
    private let fetchMyRecordsUseCase: FetchMyRecordsUseCase

    init(fetchMyRecordsUseCase: FetchMyRecordsUseCase) {
        self.fetchMyRecordsUseCase = fetchMyRecordsUseCase
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
   
    
    // MARK: - Methods
    
    func fetchMapObjects() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let motes = try await fetchMyRecordsUseCase()
                
                let summaries = motes.map { mote in
                    print("🌸 flowerImage name:", mote.marker.smallThumbnailImageName)
                    return ObjectSummary(
                        id: mote.record.id,
                        title: mote.record.title ?? "",
                        latitude: mote.record.coordinate.latitude,
                        longitude: mote.record.coordinate.longitude,
                        flowerImage: mote.marker.smallThumbnailImageName
                    )
                }
                self.objectSummaries = summaries 
                self.isLoading = false
            } catch {
                self.errorMessage = "지도를 불러오지 못했어요: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    func objectPinTapped(id: UUID) {
        guard let tapped = objectSummaries.first(where: { $0.id == id }) else { return }

        self.selectObjectDetail = tapped
        self.cameraPosition = CLLocationCoordinate2D(
            latitude: tapped.latitude,
            longitude: tapped.longitude
        )
    }
}


// 임시 ObjectSummary 구조체 정의
public struct ObjectSummary: Identifiable {
    public let id: UUID
    public let title: String
    public let latitude: Double
    public let longitude: Double
    public let flowerImage: String
    
    public init(id: UUID, title: String, latitude: Double, longitude: Double,flowerImage: String) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.flowerImage = flowerImage
    }
}
