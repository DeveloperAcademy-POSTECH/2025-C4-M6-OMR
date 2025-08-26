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
    func didDismissBottomSheet()
    
    // AR 세션 제어를 위한 새로운 메서드들
    func didPresentRecordDetail()
    func didDismissRecordDetail()
}

// MARK: - SwiftUI ViewModifier for Bottom Sheets
struct BottomSheetCoordinatorModifier: ViewModifier {
    @ObservedObject var coordinator: BottomSheetCoordinator
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.activeSheet) { sheetType in
                sheetView(for: sheetType)
            }
            .onChange(of: coordinator.activeSheet) { oldValue, newValue in
                handleSheetStateChange(from: oldValue, to: newValue)
            }
    }
    
    @ViewBuilder
    private func sheetView(for sheetType: BottomSheetType) -> some View {
        switch sheetType {
        case .flowerSelection:
            FlowerSelectionBottomSheet(
                viewModel: coordinator.flowerSelectionViewModel
            )
            
        case .recordDetail:
            if let viewModel = coordinator.recordDetailViewModel {
                RecordDetailBottomSheet(viewModel: viewModel)
            }
            
        case .saveSheet:
            if let viewModel = coordinator.saveSheetViewModel {
                RecordSaveSheetView(
                    viewModel: viewModel,
                    onCancelPlacement: {
                        coordinator.cancelPlacement()
                    }
                )
            }
        }
    }
    
    private func handleSheetStateChange(from oldValue: BottomSheetType?, to newValue: BottomSheetType?) {
        // RecordDetail이 나타날 때
        if newValue == .recordDetail && oldValue != .recordDetail {
            coordinator.delegate?.didPresentRecordDetail()
        }
        
        // RecordDetail이 사라질 때
        if oldValue == .recordDetail && newValue != .recordDetail {
            coordinator.delegate?.didDismissRecordDetail()
        }
    }
}

extension View {
    func bottomSheetCoordinator(coordinator: BottomSheetCoordinator) -> some View {
        modifier(BottomSheetCoordinatorModifier(coordinator: coordinator))
    }
}
