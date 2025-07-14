//
//  ModelContextExt.swift
//  Data
//
//  Created by eunsong on 7/15/25.
//

import SwiftData

// ModelContext는 내부적으로 Actor/Thread-safe하므로,
// 검사 생략(unchecked) 형태로 Sendable을 선언합니다.
extension ModelContext: @unchecked Sendable {}
