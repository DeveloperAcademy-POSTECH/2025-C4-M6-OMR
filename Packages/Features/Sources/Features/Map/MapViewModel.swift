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
        // MockDataProvider에서 Mote 배열 받아오기
        let mockMotes = MockDataProvider.mockObjects()
        
        // Mote를 ObjectSummary로 매핑
        self.objectSummaries = mockMotes.map { mote in
            ObjectSummary(
                id: mote.id, // 또는 mote 자체의 id가 있다면 그것 사용
                title: mote.title,
                latitude: mote.latitude,
                longitude: mote.longitude,
                flowerImage: mote.flower.objetImage
            )
        }
    }
    
    
    // 지도에서 핀(Annotation)이 탭되었을 때 호출
    func objectPinTapped(id: UUID) {
        Task {
            
            if let TappedObject = objectSummaries.first(where: { $0.id == id }) {
                self.selectObjectDetail = TappedObject
                
                // 선택된 객체 정보 출력
                print("🎯 선택된 오브제:")
                print("🆔 ID: \(TappedObject.id)")
                print("📍 위치: (\(TappedObject.latitude), \(TappedObject.longitude))")
                print("📝 제목: \(TappedObject.title)")
                print("꽃 이미지: \(TappedObject.flowerImage)")
                
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
    public let flowerImage: String
    
    public init(id: UUID, title: String, latitude: Double, longitude: Double,flowerImage: String) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.flowerImage = flowerImage
    }
}
