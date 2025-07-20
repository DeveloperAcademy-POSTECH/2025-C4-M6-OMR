//
//  ObjectAnnotation.swift
//  Features
//
//  Created by Henry on 7/18/25.
//

import MapKit
import Domain

// Domain의 ObjectSummary 데이터를 지도에 표시하기 위한 Annotation 클래스
class ObjectAnnotation: MKPointAnnotation {
    let id: UUID

    init(id: UUID, coordinate: CLLocationCoordinate2D, title: String) {
        self.id = id
        super.init()
        self.coordinate = coordinate
        self.title = title
    }
}
