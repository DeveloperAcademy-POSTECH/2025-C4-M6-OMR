//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import Dependencies
import Domain
import Foundation
import SwiftUI

@MainActor
public final class FlowerSelectionViewModel: ObservableObject {
    @Published var flowers: [FlowerModel] = []
    @Published var selectedFlower: FlowerModel?
    @Published var isLoading = false

    var onFlowerSelected: ((FlowerModel) -> Void)? {
        didSet {
            print(
                "🌸 onFlowerSelected 콜백이 설정됨: \(onFlowerSelected != nil ? "있음" : "없음")"
            )
        }
    }

    private let fetchAllMarkersUseCase: FetchAllMarkersUseCase

    init(fetchAllMarkersUseCase: FetchAllMarkersUseCase) {
        self.fetchAllMarkersUseCase = fetchAllMarkersUseCase
        print("🌸 FlowerSelectionViewModel 초기화됨")
        loadFlowers()
    }

    func selectFlower(_ flower: FlowerModel) {
        print("🌸 selectFlower 호출됨: \(flower.name)")
        print(
            "🌸 onFlowerSelected 콜백 존재: \(onFlowerSelected != nil ? "있음" : "없음")"
        )

        selectedFlower = flower
        print("🌸 selectedFlower 설정 완료: \(flower.name)")

        onFlowerSelected?(flower)
        print("🌸 onFlowerSelected 콜백 호출 완료")
    }

    public func loadFlowers() {
        print("🌸 loadFlowers 호출됨")
        isLoading = true

        Task {
            do {
                // 실제로는 UseCase를 통해 데이터를 가져와야 함
                //                flowers = FlowerModel.FlowerObjects()
                //                print("🌸 꽃 데이터 로드 완료: \(flowers.count)개")
                //                isLoading = false
                let markers = try await fetchAllMarkersUseCase()
                
                let flowerModels = markers.map { marker in
                    FlowerModel(
                        id: marker.id,
                        name: marker.displayName,
                        floriography: marker.floriography,
                        thumbnailImageName: marker.smallThumbnailImageName,
                        objectImageName: marker.imageName,
                        thumbnailLarge: marker.largeThumbnailImageName
                    )
                }

                await MainActor.run {
                    self.flowers = flowerModels
                    self.isLoading = false
                    print("🌸 꽃 데이터 로드 완료: \(flowerModels.count)개")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("🌸 꽃 데이터 로드 실패: \(error)")
                }
            }
        }
    }
}
