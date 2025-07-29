//
//  BottomSheetCoordinatorFactory.swift
//  Features
//
//  Created by eunsong on 7/29/25.
//
import Combine
import SwiftUI
import Dependencies

@MainActor
public protocol BottomSheetCoordinatorFactory: Sendable {
    func create() -> BottomSheetCoordinator
}

public struct LiveBottomSheetCoordinatorFactory: BottomSheetCoordinatorFactory {
    @MainActor
    public func create() -> BottomSheetCoordinator {
        @Dependency(\.flowerSelectionViewModelFactory) var flowerFactory
        return BottomSheetCoordinator(flowerSelectionViewModelFactory: flowerFactory)
    }
}
