//
//  FlowerSelectionViewModelFactory.swift
//  Features
//
//  Created by eunsong on 7/28/25.
//
import Dependencies
import Domain
import Foundation

@MainActor
public protocol FlowerSelectionViewModelFactory: Sendable {
    func create() -> FlowerSelectionViewModel
}

public struct LiveFlowerSelectionViewModelFactory: FlowerSelectionViewModelFactory {
    @MainActor
    public func create() -> FlowerSelectionViewModel {
        @Dependency(\.fetchAllMarkersUseCase) var fetchAllMarkersUseCase
        return FlowerSelectionViewModel(fetchAllMarkersUseCase: fetchAllMarkersUseCase)
    }
}
