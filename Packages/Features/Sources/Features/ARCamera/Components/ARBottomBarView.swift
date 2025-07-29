import DesignSystem
//
//  ARBottomBarView.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import SwiftUI

struct ARBottomBarView: View {
    let mode: ARCameraMode
    let isPlacementConfirmed: Bool
    let onSwitchToPlacement: () -> Void
    let onSelectFlower: () -> Void
    let onCancelPlacement: () -> Void
    let onConfirmPlacement: () -> Void
    let onRepositionPlacement: () -> Void
    let onSave: () -> Void

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
            }

            if isPlacementConfirmed {
                ARConfirmationButton(action: onSave)
            } else {
                Circle().fill(Color.clear).frame(width: 60, height: 60)
            }
        }
    }
}
