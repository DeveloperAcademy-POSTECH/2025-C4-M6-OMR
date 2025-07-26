import CoreLocation
import Domain
import Foundation
import UIKit

/// Domain 모델을 View에서 사용할 모델로 변환하는 Mapper
enum RecordMapper {
    static func toARRecordModel(from domain: Domain.Record) -> ARRecordModel {
        // TODO: MarkerType에 따라 적절한 3D 모델 이름을 반환하는 로직 필요
        let modelName = "test_flower"

        return ARRecordModel(
            id: domain.id,
            title: domain.title ?? "",
            coordinate: ARCoordinate(
                latitude: domain.coordinate.latitude,
                longitude: domain.coordinate.longitude
            ),
            modelName: modelName,
            createdDate: domain.date,
            authorName: "Unknown"  // TODO: 실제 작성자 이름
        )
    }

    static func toARRecordModels(from domains: [Domain.Record])
        -> [ARRecordModel]
    {
        return domains.map { toARRecordModel(from: $0) }
    }

    static func toDomainRecord(
        from placementData: ARPlacementData,
        title: String,
        description: String,
        userLocation: CLLocation,
        images: [UIImage]
    ) -> Domain.Record {
        // TODO: 이미지 저장 및 URL 변환 로직 필요
        let photoURLs = images.compactMap { _ in
            URL(string: "https://example.com/photo.jpg")
        }

        return Domain.Record(
            id: UUID(),
            authorID: UUID(),  // TODO: Replace with actual author ID
            markerTypeID: placementData.flower.id,
            title: title,
            coordinate: Domain.Coordinate(
                latitude: placementData.position.latitude,
                longitude: placementData.position.longitude
            ),
            address: Domain.Address(fullAddress: description),
            date: placementData.placedAt,
            photos: photoURLs.map { Domain.Photo(url: $0) },
            isPublic: true  // TODO: Replace with actual visibility if needed
        )
    }

    static func toARFlower(from flowerModel: FlowerModel) -> ARFlower {
        return ARFlower(
            id: flowerModel.id,
            name: flowerModel.name,
            modelName: "test_flower",  //flowerModel.objectImageName,
            floriography: flowerModel.floriography,
            thumbnail: flowerModel.thumbnailImageName
        )
    }
}
