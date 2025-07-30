import SwiftUI
import MapKit
import DesignSystem

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    @Binding var moveToUserLocation: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotationsIfNeeded(on: uiView)
        moveToUserLocationIfNeeded(on: uiView)
        moveToCameraPositionIfNeeded(on: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func updateAnnotationsIfNeeded(on mapView: MKMapView) {
        let existing = getExistingAnnotations(from: mapView)
        let (toAdd, toRemove) = calculateAnnotationDifferences(existing: existing)
        applyAnnotationChanges(to: mapView, add: toAdd, remove: toRemove)
    }

    private func moveToUserLocationIfNeeded(on mapView: MKMapView) {
        guard moveToUserLocation, let userLocation = mapView.userLocation.location else { return }
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        DispatchQueue.main.async { self.moveToUserLocation = false }
    }

    private func moveToCameraPositionIfNeeded(on mapView: MKMapView) {
        guard let position = viewModel.cameraPosition else { return }
        let region = MKCoordinateRegion(center: position, span: mapView.region.span)
        mapView.setRegion(region, animated: true)
        DispatchQueue.main.async { viewModel.cameraPosition = nil }
    }

    private func getExistingAnnotations(from mapView: MKMapView) -> [UUID: ObjectAnnotation] {
        mapView.annotations.compactMap { $0 as? ObjectAnnotation }.reduce(into: [UUID: ObjectAnnotation]()) { $0[$1.id] = $1 }
    }

    private func calculateAnnotationDifferences(existing: [UUID: ObjectAnnotation]) -> ([ObjectAnnotation], [MKAnnotation]) {
        var toAdd: [ObjectAnnotation] = []
        var toRemove: [MKAnnotation] = []

        for summary in viewModel.objectSummaries {
            let new = ObjectAnnotation(id: summary.id, coordinate: .init(latitude: summary.latitude, longitude: summary.longitude), title: summary.title)
            if let existing = existing[summary.id], existing.title != new.title {
                toRemove.append(existing)
                toAdd.append(new)
            } else if existing[summary.id] == nil {
                toAdd.append(new)
            }
        }

        let newIDs = Set(viewModel.objectSummaries.map { $0.id })
        for (id, annotation) in existing where !newIDs.contains(id) {
            toRemove.append(annotation)
        }

        return (toAdd, toRemove)
    }

    private func applyAnnotationChanges(to mapView: MKMapView, add: [ObjectAnnotation], remove: [MKAnnotation]) {
        mapView.removeAnnotations(remove)
        mapView.addAnnotations(add)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        private var hasCenteredOnUser = false
        private let bundle = Bundle(for: DesignSystemMarker.self)

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let objectAnnotation = view.annotation as? ObjectAnnotation else { return }
            parent.viewModel.objectPinTapped(id: objectAnnotation.id)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            if let cluster = annotation as? MKClusterAnnotation {
                return createClusterView(for: mapView, cluster: cluster)
            }
            return createCustomPinView(for: mapView, annotation: annotation)
        }

        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if !hasCenteredOnUser {
                let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                mapView.setRegion(region, animated: true)
                hasCenteredOnUser = true
            }
        }

        private func createClusterView(for mapView: MKMapView, cluster: MKClusterAnnotation) -> MKAnnotationView {
            let identifier = "customClusterView"
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: cluster, reuseIdentifier: identifier)
            clusterView.annotation = cluster
            clusterView.canShowCallout = false
            clusterView.frame.size = CGSize(width: 44, height: 44)

            var baseImage = UIImage(systemName: "photo")!
            if let first = cluster.memberAnnotations.compactMap({ $0 as? ObjectAnnotation }).first,
               let imageName = parent.viewModel.objectSummaries.first(where: { $0.id == first.id })?.flowerImage,
               let flowerImage = DesignSystemAssets.uiImage(named: imageName) {
                baseImage = flowerImage.resize(to: CGSize(width: 44, height: 44)) ?? baseImage
            }

            clusterView.image = makeClusterImageWithBadge(base: baseImage, count: cluster.memberAnnotations.count)
            return clusterView
        }

        private func createCustomPinView(for mapView: MKMapView, annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "customPin"
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.annotation = annotation
            annotationView.canShowCallout = false
            annotationView.clusteringIdentifier = "customPinCluster"
            annotationView.frame.size = CGSize(width: 40, height: 40)

            if annotationView.viewWithTag(1001) == nil {
                annotationView.addSubview(makeTitleLabel())
            }

            if let objectAnnotation = annotation as? ObjectAnnotation,
               let imageName = parent.viewModel.objectSummaries.first(where: { $0.id == objectAnnotation.id })?.flowerImage,
               let rawImage = DesignSystemAssets.uiImage(named: imageName),
               let resized = rawImage.resize(to: CGSize(width: 40, height: 40)) {
                annotationView.image = resized
            } else {
                annotationView.image = UIImage(systemName: "photo")?.resize(to: CGSize(width: 40, height: 40))
            }

            if let titleLabel = annotationView.viewWithTag(1001) as? UILabel {
                let text = annotation.title ?? ""
                let font = DesignSystem.Font.UIKit.Headline.medium

                let strokeTextAttributes: [NSAttributedString.Key: Any] = [
                    .strokeColor: DesignSystem.Color.UIKit.Gray_white,
                    .foregroundColor: DesignSystem.Color.UIKit.Gray_black,
                    .strokeWidth: -2.0,
                    .font: font
                ]

                titleLabel.attributedText = NSAttributedString(string: text ?? "", attributes: strokeTextAttributes)
                titleLabel.sizeToFit()
                titleLabel.frame.size.width = titleLabel.frame.width + 10
                titleLabel.center.x = annotationView.bounds.width / 2
            }
            return annotationView
        }

        private func makeClusterImageWithBadge(base: UIImage, count: Int) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: base.size)

            return renderer.image { _ in
                guard let context = UIGraphicsGetCurrentContext() else { return }

                base.draw(in: CGRect(origin: .zero, size: base.size))

                let badgeSize: CGFloat = 24
                let shadowRadius: CGFloat = 14.0
                let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
                let shadowOffset = CGSize.zero
                let badgeRect = CGRect(x: base.size.width - badgeSize - 2, y: 2, width: badgeSize, height: badgeSize)

                context.saveGState()
                context.setShadow(offset: shadowOffset, blur: shadowRadius, color: shadowColor.cgColor)

                let colors = [
                    UIColor.white.withAlphaComponent(0.2).cgColor,
                    UIColor.white.withAlphaComponent(0.4).cgColor,
                    UIColor.white.withAlphaComponent(0.52).cgColor
                ]
                let locations: [CGFloat] = [0.0, 0.78, 1.0]

                if let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: locations) {
                    let center = CGPoint(x: badgeRect.midX, y: badgeRect.midY)
                    let radius = badgeRect.width / 2
                    let badgePath = UIBezierPath(ovalIn: badgeRect)
                    badgePath.addClip()
                    context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: .drawsAfterEndLocation)
                }

                context.restoreGState()

                let font = DesignSystem.Font.UIKit.Headline.medium
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ]
                let text = "\(count)"
                let textSize = text.size(withAttributes: attributes)
                let textRect = CGRect(x: badgeRect.midX - textSize.width / 2, y: badgeRect.midY - textSize.height / 2, width: textSize.width, height: textSize.height)
                text.draw(in: textRect, withAttributes: attributes)
            }
        }

        private func makeTitleLabel() -> UILabel {
            let label = UILabel()
            label.tag = 1001
            label.font = DesignSystem.Font.UIKit.Headline.regular
            label.textColor = DesignSystem.Color.UIKit.Gray_black
            label.textAlignment = .center
            label.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = true
            label.frame = CGRect(x: -30, y: 70, width: 100, height: 20)
            return label
        }
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
}
