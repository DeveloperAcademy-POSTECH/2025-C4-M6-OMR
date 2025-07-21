//
//  MoteRepositoryKey.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//
import Dependencies
import Foundation

// MARK: - Repository Key

public struct RecordRepositoryKey: DependencyKey, Sendable {
    public static var liveValue: RecordRepository {
        fatalError("Unimplemented RecordRepository liveValue")
    }
}

public extension DependencyValues {
    var recordRepository: RecordRepository {
        get { self[RecordRepositoryKey.self] }
        set { self[RecordRepositoryKey.self] = newValue }
    }
}

// MARK: - UseCase Keys
public struct FetchPublicRecordsUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchPublicRecordsUseCase {
        fatalError("Unimplemented FetchPublicRecordsUseCase liveValue")
    }
}

public struct FetchMyRecordsUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchMyRecordsUseCase {
        fatalError("Unimplemented FetchMyRecordsUseCase liveValue")
    }
}

public struct FetchRecordDetailUseCaseKey: DependencyKey, Sendable {
    public static var liveValue: FetchRecordDetailUseCase {
        fatalError("Unimplemented FetchRecordDetailUseCase liveValue")
    }
}

public extension DependencyValues {
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
}
