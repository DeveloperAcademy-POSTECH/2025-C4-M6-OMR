import Foundation
import CoreLocation
import Domain
import Combine

@MainActor
final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Properties
    
    @Published var objectSummaries: [ObjectSummary] = []
    
    /// 핀(Annotation)을 탭했을 때 선택된 객체의 정보를 담는 프로퍼티
    @Published var selectObjectDetail: ObjectSummary? = nil
    
    
    @Published var cameraPosition: CLLocationCoordinate2D? = nil
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    
    // TODO: 향후 의존성 주입(DI) 컨테이너를 통해 UseCase를 주입
    // private let fetchUseCase: FetchNearbyMotesUseCase
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Methods
    
    // 지도에 표시할 오브젝트 데이터를 가져옴
    func fetchMapObjects() {
        
        // TODO: UseCase를 통해 실제 데이터 가져오기
        
        self.objectSummaries = (1...15).map { i in
            ObjectSummary(
                id: UUID(),
                title: "오브젝트 \(i)",
                latitude: 37.5665 + Double.random(in: -0.05...0.05),
                longitude: 126.9780 + Double.random(in: -0.05...0.05)
            )
        }
    }
    
    // 지도에서 핀(Annotation)이 탭되었을 때 호출
    func objectPinTapped(id: UUID) {
        Task {
            
            if let TappedObject = objectSummaries.first(where: { $0.id == id }) {
                self.selectObjectDetail = TappedObject
                
                // 선택된 객체의 위치로 카메라 이동
                self.cameraPosition = CLLocationCoordinate2D(
                    latitude: TappedObject.latitude,
                    longitude: TappedObject.longitude
                )
            }
        }
    }
    
}

// 임시 ObjectSummary 구조체 정의
public struct ObjectSummary: Identifiable {
    public let id: UUID
    public let title: String
    public let latitude: Double
    public let longitude: Double
    
    public init(id: UUID, title: String, latitude: Double, longitude: Double) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
}
