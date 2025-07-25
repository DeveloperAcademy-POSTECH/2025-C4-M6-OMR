import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapViewModel
    @Binding var moveToUserLocation: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Annotation 등록
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")
        
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(from: uiView)
        
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
        
        if let cameraPosition = viewModel.cameraPosition {
            let region = MKCoordinateRegion(
                center: cameraPosition,
                span: uiView.region.span
            )
            uiView.setRegion(region, animated: true)
            DispatchQueue.main.async {
                viewModel.cameraPosition = nil
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateAnnotations(from mapView: MKMapView) {
        let existingAnnotations = mapView.annotations
            .compactMap { $0 as? ObjectAnnotation }
            .reduce(into: [UUID: ObjectAnnotation]()) { dict, annotation in
                dict[annotation.id] = annotation
            }
        
        var toAdd: [ObjectAnnotation] = []
        var toRemove: [MKAnnotation] = []
        
        for summary in viewModel.objectSummaries {
            let new = ObjectAnnotation(
                id: summary.id,
                coordinate: .init(latitude: summary.latitude, longitude: summary.longitude),
                title: summary.title
            )
            if let existing = existingAnnotations[summary.id] {
                if existing.title != new.title {
                    toRemove.append(existing)
                    toAdd.append(new)
                }
            } else {
                toAdd.append(new)
            }
        }
        
        let newIDs = Set(viewModel.objectSummaries.map { $0.id })
        for (id, annotation) in existingAnnotations {
            if !newIDs.contains(id) {
                toRemove.append(annotation)
            }
        }
        
        mapView.removeAnnotations(toRemove)
        mapView.addAnnotations(toAdd)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        private var hasCenteredOnUser = false
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let objectAnnotation = view.annotation as? ObjectAnnotation else { return }
            parent.viewModel.objectPinTapped(id: objectAnnotation.id)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            
            // Cluster View
            if let cluster = annotation as? MKClusterAnnotation {
                let identifier = "customClusterView"
                var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                
                if clusterView == nil {
                    clusterView = MKAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                    clusterView?.canShowCallout = false
                    clusterView?.frame.size = CGSize(width: 44, height: 44)
                } else {
                    clusterView?.annotation = cluster
                }
                
                var baseImage = UIImage(systemName: "photo")!
                
                if let first = cluster.memberAnnotations
                    .compactMap({ $0 as? ObjectAnnotation })
                    .first,
                   let imageName = parent.viewModel.objectSummaries
                    .first(where: { $0.id == first.id })?.flowerImage,
                   let flowerImage = UIImage(named: imageName) {
                    baseImage = flowerImage.resize(to: CGSize(width: 44, height: 44)) ?? baseImage
                }
                
                let count = cluster.memberAnnotations.count
                clusterView?.image = makeClusterImageWithBadge(base: baseImage, count: count)
                return clusterView
            }
            
            // Single Pin View
            let identifier = "customPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                annotationView?.clusteringIdentifier = "customPinCluster"
                annotationView?.frame.size = CGSize(width: 40, height: 40)
                
                let titleLabel = UILabel()
                titleLabel.tag = 1001
                titleLabel.font = UIFont.systemFont(ofSize: 12)
                titleLabel.textColor = .black
                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 1
                titleLabel.backgroundColor = UIColor.white.withAlphaComponent(0.0)
                titleLabel.layer.cornerRadius = 4
                titleLabel.layer.masksToBounds = true
                titleLabel.frame = CGRect(x: -30, y: 60, width: 100, height: 20)
                
                annotationView?.addSubview(titleLabel)
            } else {
                annotationView?.annotation = annotation
                annotationView?.clusteringIdentifier = "customPinCluster"
            }
            
            if let objectAnnotation = annotation as? ObjectAnnotation,
               let imageName = parent.viewModel.objectSummaries.first(where: { $0.id == objectAnnotation.id })?.flowerImage {
                annotationView?.image = UIImage(named: imageName) ?? UIImage(systemName: "photo")
            } else {
                annotationView?.image = UIImage(systemName: "mappin.circle.fill")
            }
            
            if let titleLabel = annotationView?.viewWithTag(1001) as? UILabel {
                titleLabel.text = annotation.title ?? ""
                titleLabel.sizeToFit()
                let labelWidth = titleLabel.frame.width + 10
                titleLabel.frame.size.width = labelWidth
                titleLabel.center.x = annotationView!.bounds.width / 2
            }
            
            return annotationView
        }
        
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
        
        private func makeClusterImageWithBadge(base: UIImage, count: Int) -> UIImage {
            let badgeSize: CGFloat = 20
            let font = UIFont.boldSystemFont(ofSize: 14)
            
            let renderer = UIGraphicsImageRenderer(size: base.size)
            return renderer.image { _ in
                base.draw(in: CGRect(origin: .zero, size: base.size))
                
                let badgeRect = CGRect(
                    x: base.size.width - badgeSize - 2,
                    y: 2,
                    width: badgeSize,
                    height: badgeSize
                )
                
                let badgePath = UIBezierPath(ovalIn: badgeRect)
                UIColor.lightGray.withAlphaComponent(0.7).setFill()
                badgePath.fill()
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ]
                let text = "\(count)"
                let textSize = text.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: badgeRect.midX - textSize.width / 2,
                    y: badgeRect.midY - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                text.draw(in: textRect, withAttributes: attributes)
            }
        }
    }
}

// MARK: - UIImage Resize Extension

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
}
