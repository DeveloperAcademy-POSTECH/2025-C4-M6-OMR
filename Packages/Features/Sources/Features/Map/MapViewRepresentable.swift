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
               let flowerImage = UIImage(named: imageName) {
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
               let imageName = parent.viewModel.objectSummaries.first(where: { $0.id == objectAnnotation.id })?.flowerImage {
                annotationView.image = UIImage(named: imageName) ?? UIImage(systemName: "photo")
            } else {
                annotationView.image = UIImage(systemName: "mappin.circle.fill")
            }

            
            
            
            if let titleLabel = annotationView.viewWithTag(1001) as? UILabel {
                let text = annotation.title ?? ""
                let font = DesignSystem.Font.UIKit.Headline.medium // 14pt medium

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

        // ✨ [변경됨] Figma 디자인을 참고하여 배지 디자인을 수정한 함수입니다.
      /*  private func makeClusterImageWithBadge(base: UIImage, count: Int) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: base.size)

            return renderer.image { _ in
                // 0. 현재 그래픽 컨텍스트를 가져옵니다. 이미지에 그림을 그리기 위한 환경입니다.
                guard let context = UIGraphicsGetCurrentContext() else { return }

                // 1. 베이스 이미지를 먼저 그립니다. (꽃 모양 아이콘)
                base.draw(in: CGRect(origin: .zero, size: base.size))

                // 2. Figma에서 가져온 배지 속성을 정의합니다.
                let badgeSize: CGFloat = 24
                // Figma의 shadowRadius가 14로 매우 크기 때문에, 시각적으로 더 자연스러운 값(4.0)으로 조정했습니다.
                let shadowRadius: CGFloat = 4.0
                let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
                let shadowOffset = CGSize.zero
                
                // 배지를 우측 상단에 배치하기 위한 좌표를 계산합니다.
                let badgeRect = CGRect(x: base.size.width - badgeSize - 2, y: 2, width: badgeSize, height: badgeSize)

                // 3. 그림자 효과를 설정합니다.
                // saveGState()로 현재 그래픽 상태(그림자가 없는 상태)를 저장합니다.
                context.saveGState()
                // setShadow()로 그림자를 설정합니다. 이 설정은 이후에 그리는 모든 것에 적용됩니다.
                context.setShadow(offset: shadowOffset, blur: shadowRadius, color: shadowColor.cgColor)

                // 4. 그림자 효과가 적용된 배지(회색 원)를 그립니다.
                let badgePath = UIBezierPath(ovalIn: badgeRect)
                UIColor.lightGray.withAlphaComponent(0.7).setFill()
                badgePath.fill()
                
                // 5. 그래픽 상태를 복원합니다.
                // restoreGState()를 호출하여 이전에 저장한 상태로 되돌립니다.
                // 이렇게 해야 다음에 그리는 텍스트에는 그림자 효과가 적용되지 않습니다.
                context.restoreGState()

                // 6. 배지 위에 클러스터된 핀의 개수를 텍스트로 그립니다. (기존 코드와 동일)
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
                let textRect = CGRect(
                    x: badgeRect.midX - textSize.width / 2,
                    y: badgeRect.midY - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                text.draw(in: textRect, withAttributes: attributes)
            }
        } */
        // ✨ [변경됨] Figma 디자인과 Radial Gradient를 참고하여 배지 디자인을 수정한 함수입니다.
        private func makeClusterImageWithBadge(base: UIImage, count: Int) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: base.size)

            return renderer.image { _ in
                // 0. 현재 그래픽 컨텍스트를 가져옵니다.
                guard let context = UIGraphicsGetCurrentContext() else { return }

                // 1. 베이스 이미지를 먼저 그립니다. (꽃 모양 아이콘)
                base.draw(in: CGRect(origin: .zero, size: base.size))

                // 2. 배지 속성을 정의합니다.
                let badgeSize: CGFloat = 24
                let shadowRadius: CGFloat = 4.0
                let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
                let shadowOffset = CGSize.zero
                let badgeRect = CGRect(x: base.size.width - badgeSize - 2, y: 2, width: badgeSize, height: badgeSize)

                // 3. 그림자 효과를 위해 현재 그래픽 상태를 저장하고, 그림자를 설정합니다.
                context.saveGState()
                context.setShadow(offset: shadowOffset, blur: shadowRadius, color: shadowColor.cgColor)
                
                // 4. ✨ [새로운 로직] 방사형 그라데이션을 그립니다.
                // SwiftUI의 EllipticalGradient 코드를 CoreGraphics 코드로 변환합니다.
                let colors = [
                    UIColor.white.withAlphaComponent(0.2).cgColor,
                    UIColor.white.withAlphaComponent(0.4).cgColor,
                    UIColor.white.withAlphaComponent(0.52).cgColor
                ]
                let locations: [CGFloat] = [0.0, 0.78, 1.0]
                
                // CGGradient 객체를 생성합니다.
                if let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: locations) {
                    // 그라데이션의 시작/끝 위치와 반경을 정의합니다.
                    let center = CGPoint(x: badgeRect.midX, y: badgeRect.midY)
                    let radius = badgeRect.width / 2
                    
                    // 중요: 그라데이션이 원 밖으로 나가지 않도록 그릴 영역을 원 모양으로 제한(clip)합니다.
                    let badgePath = UIBezierPath(ovalIn: badgeRect)
                    badgePath.addClip()
                    
                    // 방사형 그라데이션을 그립니다.
                    context.drawRadialGradient(
                        gradient,
                        startCenter: center,
                        startRadius: 0,
                        endCenter: center,
                        endRadius: radius,
                        options: .drawsAfterEndLocation // 끝 위치 이후까지 색상을 채웁니다.
                    )
                }
                
                // 5. 그래픽 상태를 복원합니다. (그림자 및 클리핑 경로 제거)
                context.restoreGState()

                // 6. 배지 위에 클러스터된 핀의 개수를 텍스트로 그립니다.
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
                let textRect = CGRect(
                    x: badgeRect.midX - textSize.width / 2,
                    y: badgeRect.midY - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                text.draw(in: textRect, withAttributes: attributes)
            }
        }
        
        private func makeTitleLabel() -> UILabel {
            let label = UILabel()
            label.tag = 1001
            label.font = DesignSystem.Font.UIKit.Headline.regular // 14pt regular
            label.textColor = DesignSystem.Color.UIKit.Gray_black // DesignSystem 검은색
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
