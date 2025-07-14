//
//  MoteRepositoryKey.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Dependencies
import Foundation
// MARK: - Repository Key

public enum MoteRepositoryKey: DependencyKey {
    public static var liveValue: MoteRepository {
        fatalError("Unimplemented MoteRepository liveValue")
    }
}

public extension DependencyValues {
    var moteRepository: MoteRepository {
        get { self[MoteRepositoryKey.self] }
        set { self[MoteRepositoryKey.self] = newValue }
    }
}

// MARK: - UseCase Keys
public enum FetchNearbyMotesUseCaseKey: DependencyKey {
    public static var liveValue: FetchNearbyMotesUseCase {
        fatalError("Unimplemented FetchNearbyMotesUseCase liveValue")
    }
}

public enum FetchMyMotesUseCaseKey: DependencyKey {
    public static var liveValue: FetchMyMotesUseCase {
        fatalError("Unimplemented FetchMyMotesUseCase liveValue")
    }
}

public enum FetchMoteDetailUseCaseKey: DependencyKey {
    public static var liveValue: FetchMoteDetailUseCase {
        fatalError("Unimplemented FetchMoteDetailUseCase liveValue")
    }
}

public extension DependencyValues {
    var fetchNearbyMotesUseCase: FetchNearbyMotesUseCase {
        get { self[FetchNearbyMotesUseCaseKey.self] }
        set { self[FetchNearbyMotesUseCaseKey.self] = newValue }
    }
    var fetchMyMotesUseCase: FetchMyMotesUseCase {
        get { self[FetchMyMotesUseCaseKey.self] }
        set { self[FetchMyMotesUseCaseKey.self] = newValue }
    }
    var fetchMoteDetailUseCase: FetchMoteDetailUseCase {
        get { self[FetchMoteDetailUseCaseKey.self] }
        set { self[FetchMoteDetailUseCaseKey.self] = newValue }
    }
}
