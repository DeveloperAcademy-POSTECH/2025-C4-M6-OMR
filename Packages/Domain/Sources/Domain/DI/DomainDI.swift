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

// MARK: - UseCase Keys (✅ 지연 생성으로 변경)

public struct FetchMyRecordsUseCaseKey: DependencyKey, Sendable {
    // ✅ Repository가 주입된 후에 생성되도록 지연 생성
    public static var liveValue: FetchMyRecordsUseCase {
        FetchMyRecordsUseCase()
    }
}

public struct SaveRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: SaveRecordUseCase {
        SaveRecordUseCase()
    }
}

public struct InitializeAppDataUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: InitializeAppDataUseCase {
        InitializeAppDataUseCase()
    }
}

public struct FetchAllMarkersUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchAllMarkersUseCase {
        FetchAllMarkersUseCase()
    }
}

// 나머지 UseCase들도 동일하게 지연 생성
public struct FetchPublicRecordsUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchPublicRecordsUseCase {
        .init()
    }
}

public struct FetchRecordDetailUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchRecordDetailUseCase {
        .init()
    }
}

public struct DeleteRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: DeleteRecordUseCase {
        .init()
    }
}

public struct UpdateRecordUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: UpdateRecordUseCase {
        .init()
    }
}

// MARK: - DependencyValues Extension (동일)

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

    public var initializeAppDataUseCase: InitializeAppDataUseCase {
        get { self[InitializeAppDataUseCaseKey.self] }
        set { self[InitializeAppDataUseCaseKey.self] = newValue }
    }

    public var fetchAllMarkersUseCase: FetchAllMarkersUseCase {
        get { self[FetchAllMarkersUseCaseKey.self] }
        set { self[FetchAllMarkersUseCaseKey.self] = newValue }
    }
}

// MARK: - Unimplemented Repository Placeholders (동일)

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

    func getOrCreateDefaultUser() async throws -> User {
        throw UnimplementedError()
    }

    func initializeDefaultUser() async throws {
        throw UnimplementedError()
    }
}

private struct UnimplementedMarkerRepository: MarkerRepository {
    func fetch(by id: UUID) async throws -> Marker {
        throw UnimplementedError()
    }

    func initializeDefaultMarkers() async throws {
        throw UnimplementedError()
    }

    func fetchAll() async throws -> [Marker] {
        throw UnimplementedError()
    }
}

// MARK: - Error

private struct UnimplementedError: LocalizedError {
    var errorDescription: String? {
        "This dependency has not been properly injected. Please ensure you've used .injectAppDependencies() on your root view."
    }
}
