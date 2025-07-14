//
//  UserRepository.swift
//  Domain
//
//  Created by eunsong on 7/15/25.
//

import Foundation

public protocol UserRepository: Sendable {
    /// 현재 로그인한 사용자를 로컬 또는 원격에서 조회
//    func fetchCurrentUser() async throws -> User
}
