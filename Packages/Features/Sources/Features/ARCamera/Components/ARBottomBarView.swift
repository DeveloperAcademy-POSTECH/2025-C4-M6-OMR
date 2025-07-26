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
        Button(action: onSwitchToPlacement) {
            Image(systemName: "plus")
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding(20)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 10)
        }
    }

    private var placementModeButtons: some View {
        HStack(spacing: 30) {
            Button(action: onCancelPlacement) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Button(
                action: isPlacementConfirmed
                    ? onRepositionPlacement : onConfirmPlacement
            ) {
                Image(
                    systemName: isPlacementConfirmed
                        ? "arrow.uturn.backward" : "checkmark"
                )
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding(20)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 10)
            }

            if isPlacementConfirmed {
                Button(action: onSave) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
            } else {
                Circle().fill(Color.clear).frame(width: 60, height: 60)
            }
        }
    }
}
