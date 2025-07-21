//
//  RecordDetailDTO.swift
//  Data
//
//  Created by eunsong on 7/20/25.
//

import Foundation

/// SwiftData에서 Prefetch한 RecordEntity, UserEntity, MarkerEntity를
/// 한 번에 묶어서 도메인 RecordDetail으로 변환하기 위한 DTO
struct RecordDetailDTO {
    let record: RecordEntity
    let author: UserEntity
    let marker: MarkerEntity

    /// RecordModel으로 변환
    func toModel() -> RecordModel {
        let decoder = JSONDecoder()
        let decodedPhotoURLs = (try? decoder.decode([String].self, from: self.record.photoURLs.data(using: .utf8)!)) ?? []

        return RecordModel(
            id: record.id,
            title: record.title,
            latitude: record.latitude,
            longitude: record.longitude,
            address: record.address,
            date: record.date,
            photoURLs: decodedPhotoURLs,
            isPublic: record.isPublic,
            authorID: author.id,
            markerID: marker.id
        )
    }
}
