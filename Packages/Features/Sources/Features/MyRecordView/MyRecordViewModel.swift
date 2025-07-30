//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/25/25.
//

import Foundation

struct MyRecordModel: Identifiable {
    let id: UUID
    let title: String
    let createdAt: Date
    let flowerImageName: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 dd일"
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Mock Creator
    static func createMock() -> [MyRecordModel] {
        return MockDataProvider.mockObjects().map { mote in
            MyRecordModel(
                id: mote.id,
                title: mote.title,
                createdAt: mote.createdAt,
                flowerImageName: mote.flower.objetImage
            )
        }
    }
}

import Combine
import Foundation
import CoreLocation
import Domain

@MainActor
final class MyRecordViewModel: ObservableObject {
    @Published var records: [MyRecordModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let fetchMyRecordsUseCase: FetchMyRecordsUseCase

    init(fetchMyRecordsUseCase: FetchMyRecordsUseCase) {
        self.fetchMyRecordsUseCase = fetchMyRecordsUseCase
        loadRecords()
    }

    func loadRecords() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let recordDetails = try await fetchMyRecordsUseCase()

                let models = recordDetails.map { detail in
                    MyRecordModel(
                        id: detail.record.id,
                        title: detail.record.title ?? "",
                        createdAt: detail.record.date,
                        flowerImageName: detail.marker.largeThumbnailImageName
                    )
                }

                await MainActor.run {
                    self.records = models.sorted(by: { $0.createdAt > $1.createdAt })
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "기록을 불러오는 데 실패했어요: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}


