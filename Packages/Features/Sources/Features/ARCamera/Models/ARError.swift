//
//  ARError.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import Foundation

public enum ARError: LocalizedError {
    case sessionFailed(String)
    case placementFailed(String)
    case saveFailed(String)
    case locationAccessDenied
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .sessionFailed(let message):
            return "AR 세션 오류: \(message)"
        case .placementFailed(let message):
            return "배치 오류: \(message)"
        case .saveFailed(let message):
            return "저장 오류: \(message)"
        case .locationAccessDenied:
            return "위치 권한이 필요합니다"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}
