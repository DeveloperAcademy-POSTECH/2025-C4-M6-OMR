import DesignSystem
//
//  ARBottomBarView.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import SwiftUI

@available(iOS 18.0, *)
struct ARBottomBarView: View {
    let mode: ARCameraMode
    let isPlacementConfirmed: Bool
    let onSwitchToPlacement: () -> Void
    let onSelectFlower: () -> Void
    let onCancelPlacement: () -> Void
    let onConfirmPlacement: () -> Void
    let onRepositionPlacement: () -> Void
    let onSave: () -> Void
    let status: ARSceneManager.RaycastStatus

    var body: some View {
        switch mode {
        case .normal:
            normalModeButton
        case .placement:
            placementModeButtons
        }
    }

    private var normalModeButton: some View {
        ARPlusButton(action: onSwitchToPlacement)
    }

    private var placementModeButtons: some View {
        HStack(spacing: 30) {
            if !isPlacementConfirmed {
                ARFlowerButton(action: onSelectFlower)
            } else {
                Circle().fill(Color.clear).frame(width: 60, height: 60)
            }
           

            if isPlacementConfirmed {
                ARBackWardButton(action: onRepositionPlacement)
            } else {
                ARCheckButton(action: onConfirmPlacement)
                    .disabled(!getStatus())
                      .opacity(getStatus() ? 1.0 : 0.4) // 상태 표시를 위해 반투명 처리
            }

            if isPlacementConfirmed {
                ARConfirmationButton(action: onSave)
            } else {
                Circle().fill(Color.clear).frame(width: 60, height: 60)
            }
        }
    }
    
    private func getStatus() -> Bool {
        switch status {
        case .idle:
            return false
        case .success:
            return true
        case .fallback:
            return false
        case .failed:
            return true
        }
    }
}
