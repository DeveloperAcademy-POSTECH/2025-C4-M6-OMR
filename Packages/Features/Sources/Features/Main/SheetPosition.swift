//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/18/25.
//

import UIKit

@MainActor
enum SheetPosition {
    case half
    case full

    var yOffset: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        switch self {
        case .half:
            return screenHeight * 0.8
        case .full:
            return 0
        }
    }
}
