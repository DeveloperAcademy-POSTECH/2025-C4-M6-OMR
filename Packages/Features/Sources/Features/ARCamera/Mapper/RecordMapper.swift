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
        userLocation: CLLocation,
        payload: FinalRecordPayload
    ) -> Domain.Record {
        // TODO: 이미지 저장 및 URL 변환 로직 필요
        let photoURLs = payload.imageFileNames.compactMap { image in
            URL(string: image)
        }

        // ✅ 최종 저장되는 위치 정보 로그
        let finalLatitude = placementData.position.latitude
        let finalLongitude = placementData.position.longitude
        print("💾 =====  Record 저장 위치 정보 =====")
        print("💾 최종 저장 좌표: (\(String(format: "%.6f", finalLatitude)), \(String(format: "%.6f", finalLongitude)))")
        print("📱 사용자 현재 위치: (\(String(format: "%.6f", userLocation.coordinate.latitude)), \(String(format: "%.6f", userLocation.coordinate.longitude)))")
        
        // 거리 계산
        let finalLocation = CLLocation(latitude: finalLatitude, longitude: finalLongitude)
        let distance = userLocation.distance(from: finalLocation)
        print("📏 사용자로부터 거리: \(String(format: "%.2f", distance))m")
        print("===============================")

        return Domain.Record(
            id: UUID(),
            authorID: UUID(),  // TODO: Replace with actual author ID
            markerTypeID: placementData.flower.id,
            coordinate: Domain.Coordinate(
                latitude: finalLatitude,
                longitude: finalLongitude
            ),
            address: Domain.Address(fullAddress: payload.description),
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
