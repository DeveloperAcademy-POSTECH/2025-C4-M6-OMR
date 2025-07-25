import Foundation
import Domain

/// Domain 모델을 View에서 사용할 모델로 변환하는 Mapper
enum RecordMapper {
    static func toARRecordModel(from domain: Domain.Record) -> ARRecordModel {
        // TODO: MarkerType에 따라 적절한 3D 모델 이름을 반환하는 로직 필요
        let modelName = "daisy_low_poly"
        
        return ARRecordModel(
            id: domain.id,
            title: domain.title ?? "",
            coordinate: ARCoordinate(latitude: domain.coordinate.latitude, longitude: domain.coordinate.longitude),
            modelName: modelName
        )
    }
    
    static func toARRecordModels(from domains: [Domain.Record]) -> [ARRecordModel] {
        return domains.map { toARRecordModel(from: $0) }
    }
    
    static func toDomainRecord(
        flower: ARFlower,
        arRecordModel: ARRecordModel
    ) -> Domain.Record {
        return Domain.Record(
            id: UUID(),
            authorID: UUID(), // TODO: Replace with actual author ID
            markerTypeID: flower.id,
            title: arRecordModel.title,
            coordinate: Domain.Coordinate(
                latitude: arRecordModel.coordinate.latitude,
                longitude: arRecordModel.coordinate.longitude
            ),
            address: Domain.Address(fullAddress: ""), // TODO: Replace with actual address
            date: Date(), // TODO: Replace with actual date if available
            photos: [], // TODO: Replace with actual photo list
            isPublic: true // TODO: Replace with actual visibility if needed
        )
    }
}
