//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/22/25.
//

import Foundation

extension DateFormatter {
    static let moteDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()
}
