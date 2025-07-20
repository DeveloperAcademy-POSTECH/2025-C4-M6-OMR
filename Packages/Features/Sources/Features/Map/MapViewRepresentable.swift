import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapViewModel
    
    @Binding var moveToUserLocation: Bool
    
    // MARK: - Representable Lifecycle
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        
        // Annotation 및 Cluster View 등록
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        // 기본 지도 속성 설정
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // ViewModel의 데이터가 변경되면 지도의 핀을 업데이트
        updateAnnotations(from: uiView)
        
        // '내 위치로 이동' 기능
        if moveToUserLocation {
            if let userLocation = uiView.userLocation.location {
                let region = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                uiView.setRegion(region, animated: true)
            }
            
            DispatchQueue.main.async {
                self.moveToUserLocation = false
            }
        }
        
        // 선택된 핀으로 카메라 위치 이동
        if let cameraPosition = viewModel.cameraPosition {
            let region = MKCoordinateRegion(
                center: cameraPosition,
                span: uiView.region.span
            )
            uiView.setRegion(region, animated: true)
            
            // 카메라 위치 초기화
            DispatchQueue.main.async {
                viewModel.cameraPosition = nil
            }
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Helper
    
    private func updateAnnotations(from mapView: MKMapView) {
        let existingAnnotations = mapView.annotations
            .compactMap { $0 as? ObjectAnnotation }
            .reduce(into: [UUID: ObjectAnnotation]()) { dictionary, annotation in
                dictionary[annotation.id] = annotation
            }
        
        var annotationsToAdd: [ObjectAnnotation] = []
        var annotationsToRemove: [MKAnnotation] = []
        
        for summary in viewModel.objectSummaries {
            let newAnnotation = ObjectAnnotation(
                id: summary.id,
                coordinate: .init(latitude: summary.latitude, longitude: summary.longitude),
                title: summary.title
            )
            
            if let existingAnnotation = existingAnnotations[summary.id] {
                // ID는 같지만 제목이 다르면 업데이트
                if existingAnnotation.title != newAnnotation.title {
                    annotationsToRemove.append(existingAnnotation)
                    annotationsToAdd.append(newAnnotation)
                }
            } else {
                // 기존에 없던 ID인 경우 새로 추가
                annotationsToAdd.append(newAnnotation)
            }
        }
        
        // 새 데이터에 포함되지 않은 나머지 핀은 제거
        let newAnnotationIDs = Set(viewModel.objectSummaries.map { $0.id })
        for (id, annotation) in existingAnnotations {
            if !newAnnotationIDs.contains(id) {
                annotationsToRemove.append(annotation)
            }
        }
        
        mapView.removeAnnotations(annotationsToRemove)
        mapView.addAnnotations(annotationsToAdd)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        
        // Coordinator는 MapViewRepresentable의 delegate 역할을 수행
        var parent: MapViewRepresentable
        private var hasCenteredOnUser = false
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let objectAnnotation = view.annotation as? ObjectAnnotation else { return }
            
            // parent를 통해 ViewModel의 함수를 호출하여 탭 이벤트를 전달
            parent.viewModel.objectPinTapped(id: objectAnnotation.id)
        }
        
        // 지도에 핀을 어떻게 표시할지 결정
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 사용자 위치는 기본 파란 점으로 표시
            if annotation is MKUserLocation { return nil }
            
            if let cluster = annotation as? MKClusterAnnotation {
                // 클러스터 뷰 설정
                guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: cluster) as? MKMarkerAnnotationView else {
                    return nil
                }
                view.glyphText = "\(cluster.memberAnnotations.count)"
                return view
            }
            
            // 일반 핀(마커) 뷰 설정
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: "marker", for: annotation) as? MKMarkerAnnotationView else { return nil }
            view.clusteringIdentifier = "marker"
            return view
        }
        
        // 사용자 위치가 처음 업데이트될 때 한 번만 지도를 중앙으로 이동
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if !hasCenteredOnUser {
                let region = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
                mapView.setRegion(region, animated: true)
                hasCenteredOnUser = true
            }
        }
    }
}
