// DependencyKeys.swift
// Domain/Sources/Domain/DI

import Dependencies
import Foundation

// MARK: - Repository Keys

public struct RecordRepositoryKey: DependencyKey, Sendable {
    public static var liveValue: RecordRepository {
        fatalError("RecordRepositoryKey.liveValue has not been implemented.")
    }
}

public struct UserRepositoryKey: DependencyKey, Sendable {
    public static var liveValue: UserRepository {
        fatalError("UserRepositoryKey.liveValue has not been implemented.")
    }
}

public struct MarkerRepositoryKey: DependencyKey, Sendable {
    public static var liveValue: MarkerRepository {
        fatalError("MarkerRepositoryKey.liveValue has not been implemented.")
    }
}

// MARK: - UseCase Keys

public struct FetchPublicRecordsUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchPublicRecordsUseCase {
        FetchPublicRecordsUseCase(
            recordRepository:  DependencyValues().recordRepository,
            userRepository:    DependencyValues().userRepository,
            markerRepository:  DependencyValues().markerRepository
        )
    }
}

public struct FetchMyRecordsUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchMyRecordsUseCase {
        FetchMyRecordsUseCase(
            recordRepository:  DependencyValues().recordRepository,
            userRepository:    DependencyValues().userRepository,
            markerRepository:  DependencyValues().markerRepository
        )
    }
}

public struct FetchRecordDetailUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchRecordDetailUseCase {
        FetchRecordDetailUseCase(
            recordRepository:  DependencyValues().recordRepository,
            userRepository:    DependencyValues().userRepository,
            markerRepository:  DependencyValues().markerRepository
        )
    }
}

public struct SaveRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: SaveRecordUseCase {
        SaveRecordUseCase(
            repo: DependencyValues().recordRepository
        )
    }
}

public struct DeleteRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: DeleteRecordUseCase {
        DeleteRecordUseCase(
            repo: DependencyValues().recordRepository
        )
    }
}

public struct UpdateRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: UpdateRecordUseCase {
        UpdateRecordUseCase(
            repo: DependencyValues().recordRepository
        )
    }
}

// MARK: - DependencyValues Extension

public extension DependencyValues {
    // Repositories
    var recordRepository: RecordRepository {
        get { self[RecordRepositoryKey.self] }
        set { self[RecordRepositoryKey.self] = newValue }
    }

    var userRepository: UserRepository {
        get { self[UserRepositoryKey.self] }
        set { self[UserRepositoryKey.self] = newValue }
    }

    var markerRepository: MarkerRepository {
        get { self[MarkerRepositoryKey.self] }
        set { self[MarkerRepositoryKey.self] = newValue }
    }

    // UseCases
    var fetchPublicRecordsUseCase: FetchPublicRecordsUseCase {
        get { self[FetchPublicRecordsUseCaseKey.self] }
        set { self[FetchPublicRecordsUseCaseKey.self] = newValue }
    }

    var fetchMyRecordsUseCase: FetchMyRecordsUseCase {
        get { self[FetchMyRecordsUseCaseKey.self] }
        set { self[FetchMyRecordsUseCaseKey.self] = newValue }
    }

    var fetchRecordDetailUseCase: FetchRecordDetailUseCase {
        get { self[FetchRecordDetailUseCaseKey.self] }
        set { self[FetchRecordDetailUseCaseKey.self] = newValue }
    }

    var saveRecordUseCase: SaveRecordUseCase {
        get { self[SaveRecordUseCaseKey.self] }
        set { self[SaveRecordUseCaseKey.self] = newValue }
    }

    var deleteRecordUseCase: DeleteRecordUseCase {
        get { self[DeleteRecordUseCaseKey.self] }
        set { self[DeleteRecordUseCaseKey.self] = newValue }
    }

    var updateRecordUseCase: UpdateRecordUseCase {
        get { self[UpdateRecordUseCaseKey.self] }
        set { self[UpdateRecordUseCaseKey.self] = newValue }
    }
}
