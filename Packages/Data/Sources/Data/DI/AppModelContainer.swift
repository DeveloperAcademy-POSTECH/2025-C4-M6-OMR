//
//  AppModelContainer.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//

import SwiftData

public enum AppModelContainer {
    public static let shared: ModelContainer = {
        let schema = Schema([
            MoteEntity.self,
            UserEntity.self,
                // 필요한 Entity들을 추가
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }()
}
