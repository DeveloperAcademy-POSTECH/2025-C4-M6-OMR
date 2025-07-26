//
//  ARCameraMode.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//

public enum ARCameraMode: Equatable {
    case normal
    case placement

    var description: String {
        switch self {
        case .normal: return "일반 모드"
        case .placement: return "배치 모드"
        }
    }
}
