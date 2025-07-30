//
//  FlowerSelectionViewModelFactory.swift
//  Features
//
//  Created by eunsong on 7/28/25.
//
import Dependencies
import Domain
import Foundation

public protocol FlowerSelectionViewModelFactory: Sendable {
    @MainActor func create() -> FlowerSelectionViewModel
}

public struct LiveFlowerSelectionViewModelFactory: FlowerSelectionViewModelFactory {
    public init() {}
    
    @MainActor
    public func create() -> FlowerSelectionViewModel {
        @Dependency(\.fetchAllMarkersUseCase) var fetchAllMarkersUseCase
        return FlowerSelectionViewModel(fetchAllMarkersUseCase: fetchAllMarkersUseCase)
    }
}
