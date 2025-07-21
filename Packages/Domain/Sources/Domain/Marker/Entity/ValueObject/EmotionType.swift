//
//  EmotionType.swift
//  Domain
//
//  Created by eunsong on 7/20/25.
//

public enum EmotionType: String, CaseIterable, Sendable {
    case all, joy, sadness, emotion1, emotion2
    public var displayName: String { self.rawValue }
}
