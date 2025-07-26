//
//  BottomSheetCoordinatorDelegate.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import SwiftUI

// MARK: - BottomSheetCoordinatorDelegate
@MainActor
protocol BottomSheetCoordinatorDelegate: AnyObject {
    func didSelectFlower(_ flower: FlowerModel)
    func didSaveRecord(title: String, description: String)
}

// MARK: - SwiftUI ViewModifier for Bottom Sheets
struct BottomSheetCoordinatorModifier: ViewModifier {
    @ObservedObject var coordinator: BottomSheetCoordinator

    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.activeSheet) { sheetType in
                sheetView(for: sheetType)
            }
    }

    @ViewBuilder
    private func sheetView(for sheetType: BottomSheetType) -> some View {
        switch sheetType {
        case .flowerSelection:
            FlowerSelectionBottomSheet(
                viewModel: coordinator.flowerSelectionViewModel
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)

        case .recordDetail:
            if let viewModel = coordinator.recordDetailViewModel {
                RecordDetailBottomSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }

        case .saveSheet:
            if let viewModel = coordinator.saveSheetViewModel {
                RecordSaveSheetView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

extension View {
    func bottomSheetCoordinator(coordinator: BottomSheetCoordinator)
        -> some View
    {
        modifier(BottomSheetCoordinatorModifier(coordinator: coordinator))
    }
}
