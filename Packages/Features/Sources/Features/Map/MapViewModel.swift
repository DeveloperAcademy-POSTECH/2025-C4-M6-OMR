import Foundation
import CoreLocation
import Domain
import Combine
import Dependencies

@MainActor
final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Properties
    
    @Published var objectSummaries: [ObjectSummary] = []
    
    /// 핀(Annotation)을 탭했을 때 선택된 객체의 정보를 담는 프로퍼티
    @Published var selectObjectDetail: ObjectSummary? = nil
    
    
    @Published var cameraPosition: CLLocationCoordinate2D? = nil
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    
    private let fetchMyRecordsUseCase: FetchMyRecordsUseCase
    
    // TODO: 향후 의존성 주입(DI) 컨테이너를 통해 UseCase를 주입
    // private let fetchUseCase: FetchNearbyMotesUseCase
    
    // MARK: - Initialization
    
    init(fetchMyRecordsUseCase: FetchMyRecordsUseCase) {
        self.fetchMyRecordsUseCase = fetchMyRecordsUseCase
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Methods
    
    // 지도에 표시할 오브젝트 데이터를 가져옴
    
    func fetchMapObjects() {
        Task {
            do {
                // ✅ UseCase를 통해 실제 기록 데이터를 가져옵니다.
                let records = try await fetchMyRecordsUseCase()
                
                // ✅ 가져온 Record를 ObjectSummary로 매핑합니다.
                self.objectSummaries = records.map { record in
                    ObjectSummary(
                        id: record.record.id,
                        title: record.record.title ?? "제목 없음",
                        latitude: record.record.coordinate.latitude,
                        longitude: record.record.coordinate.longitude,
                        // Marker 정보에서 이미지를 가져와야 할 수 있습니다.
                        flowerImage: record.marker.imageName
                    )
                }
            } catch {
                print(" 지도 기록 가져오기 실패: \(error.localizedDescription)")
            }
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
