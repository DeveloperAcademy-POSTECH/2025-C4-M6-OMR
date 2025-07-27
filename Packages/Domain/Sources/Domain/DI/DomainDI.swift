import Dependencies
import Foundation

// MARK: - Repository Keys

public struct RecordRepositoryKey: DependencyKey, Sendable {
    public static let liveValue: RecordRepository =
        UnimplementedRecordRepository()
}

public struct UserRepositoryKey: DependencyKey, Sendable {
    public static let liveValue: UserRepository = UnimplementedUserRepository()
}

public struct MarkerRepositoryKey: DependencyKey, Sendable {
    public static let liveValue: MarkerRepository =
        UnimplementedMarkerRepository()
}

// MARK: - UseCase Keys

public struct FetchMyRecordsUseCaseKey: DependencyKey, Sendable {
    public static let liveValue = FetchMyRecordsUseCase()
}

public struct FetchPublicRecordsUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchPublicRecordsUseCase {
        @Dependency(\.recordRepository) var recordRepository
        @Dependency(\.userRepository) var userRepository
        @Dependency(\.markerRepository) var markerRepository
        return .init(
            recordRepository: recordRepository,
            userRepository: userRepository,
            markerRepository: markerRepository
        )
    }
}

public struct FetchRecordDetailUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchRecordDetailUseCase {
        @Dependency(\.recordRepository) var recordRepository
        @Dependency(\.userRepository) var userRepository
        @Dependency(\.markerRepository) var markerRepository
        return .init(
            recordRepository: recordRepository,
            userRepository: userRepository,
            markerRepository: markerRepository
        )
    }
}

public struct SaveRecordUseCaseKey: DependencyKey, Sendable {
    public static let liveValue = SaveRecordUseCase()
}

public struct DeleteRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: DeleteRecordUseCase {
        @Dependency(\.recordRepository) var recordRepository
        return .init(repo: recordRepository)
    }
}

public struct UpdateRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: UpdateRecordUseCase {
        @Dependency(\.recordRepository) var recordRepository
        return .init(repo: recordRepository)
    }
}

// MARK: - DependencyValues Extension

extension DependencyValues {
    public var recordRepository: RecordRepository {
        get { self[RecordRepositoryKey.self] }
        set { self[RecordRepositoryKey.self] = newValue }
    }

    public var userRepository: UserRepository {
        get { self[UserRepositoryKey.self] }
        set { self[UserRepositoryKey.self] = newValue }
    }

    public var markerRepository: MarkerRepository {
        get { self[MarkerRepositoryKey.self] }
        set { self[MarkerRepositoryKey.self] = newValue }
    }

    public var fetchMyRecordsUseCase: FetchMyRecordsUseCase {
        get { self[FetchMyRecordsUseCaseKey.self] }
        set { self[FetchMyRecordsUseCaseKey.self] = newValue }
    }

    public var fetchPublicRecordsUseCase: FetchPublicRecordsUseCase {
        get { self[FetchPublicRecordsUseCaseKey.self] }
        set { self[FetchPublicRecordsUseCaseKey.self] = newValue }
    }

    public var fetchRecordDetailUseCase: FetchRecordDetailUseCase {
        get { self[FetchRecordDetailUseCaseKey.self] }
        set { self[FetchRecordDetailUseCaseKey.self] = newValue }
    }

    public var saveRecordUseCase: SaveRecordUseCase {
        get { self[SaveRecordUseCaseKey.self] }
        set { self[SaveRecordUseCaseKey.self] = newValue }
    }

    public var deleteRecordUseCase: DeleteRecordUseCase {
        get { self[DeleteRecordUseCaseKey.self] }
        set { self[DeleteRecordUseCaseKey.self] = newValue }
    }

    public var updateRecordUseCase: UpdateRecordUseCase {
        get { self[UpdateRecordUseCaseKey.self] }
        set { self[UpdateRecordUseCaseKey.self] = newValue }
    }
}

// MARK: - Unimplemented Repository Placeholders

private struct UnimplementedRecordRepository: RecordRepository {
    func fetchMyRecords(in filter: LocationFilter?) async throws -> [Record] {
        throw UnimplementedError()
    }

    func fetchRecordDetail(id: UUID) async throws -> Record {
        throw UnimplementedError()
    }

    func fetchPublicRecords(in filter: LocationFilter) async throws -> [Record]
    {
        throw UnimplementedError()
    }

    func save(_ record: Record) async throws {
        throw UnimplementedError()
    }

    func update(_ record: Record) async throws {
        throw UnimplementedError()
    }

    func delete(_ record: Record) async throws {
        throw UnimplementedError()
    }
}

private struct UnimplementedUserRepository: UserRepository {
    func fetch(by id: UUID) async throws -> User {
        throw UnimplementedError()
    }
}

private struct UnimplementedMarkerRepository: MarkerRepository {
    func fetch(by id: UUID) async throws -> Marker {
        throw UnimplementedError()
    }
}

// MARK: - Error

private struct UnimplementedError: LocalizedError {
    var errorDescription: String? {
        "This dependency has not been properly injected. Please ensure you've used .injectAppDependencies() on your root view."
    }
}
