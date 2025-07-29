//
//  RecordSaveSheetView.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//

import SwiftUI
import PhotosUI
import Domain
import DesignSystem

public struct RecordSaveSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecordSaveSheetViewModel
    private let onCancelPlacement: () -> Void
    
    public init(
        viewModel: RecordSaveSheetViewModel,
        onCancelPlacement: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCancelPlacement = onCancelPlacement
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            RecordSaveHeaderView(
                onRequestCancel: { },
                onConfirmCancel: {
                    onCancelPlacement()
                    dismiss()
                }
            )
            
            VStack(spacing: 0) {
                SelectedFlowerCardView(
                    flowerName: viewModel.flowerName,
                    flowerMeaning: viewModel.flowerMeaning,
                    flowerImageName: viewModel.flowerImageName
                )
                .padding(.bottom, 30)
                
                PhotoSelectionView(viewModel: viewModel)
                    .padding(.bottom, 20)
            }
            
            SaveButtonView(
                isDisabled: viewModel.isSaveButtonDisabled,
                viewModel: viewModel,
                dismiss: { dismiss() }
            )
            Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents([.fraction(0.8)])
        .interactiveDismissDisabled(true)
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Subviews

private struct RecordSaveHeaderView: View {
    let onRequestCancel: () -> Void
    let onConfirmCancel: () -> Void
    @State private var showCancelAlert = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button(action: {
                    showCancelAlert = true
                    onRequestCancel()
                }) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Color.Gray_Button)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Color.Gray_black.opacity(0.25))
                    }
                }
                .alert(
                    "꽃 심기를 그만두실래요?",
                    isPresented: $showCancelAlert
                ) {
                    Button("그만둘래요", role: .destructive) {
                        onConfirmCancel()
                    }
                    Button("계속할래요", role: .cancel) {
                    }
                } message: {
                    Text("방금 배치한 꽃은 사라지게 됩니다")
                }
            }
            
            Text("꽃 심기 완료!")
                .font(DesignSystem.Font.custom(size: 18, weight: .bold))
            
            Text("함께 기억할 사진과 글을 저장해주세요.")
                .font(DesignSystem.Font.custom(size: 18, weight: .bold))
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
}

private struct SelectedFlowerCardView: View {
    let flowerName: String
    let flowerMeaning: String
    let flowerImageName: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                DesignSystemAssets.image(named: "MainFlower")
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text(flowerName)
                    .font(DesignSystem.Font.custom(size: 16, weight: .medium))
            }
            
            Text(flowerMeaning)
                .font(DesignSystem.Font.custom(size: 14, weight: .regular))
                .foregroundColor(DesignSystem.Color.Prime2)
            
            DesignSystemAssets.image(named: flowerImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
        }
        .padding(.top, 14)
        .padding(.bottom, 30)
        .padding(.horizontal, 45)
        .background(DesignSystem.Color.Gray_01)
        .cornerRadius(20)
    }
}

private struct SaveButtonView: View {
    let isDisabled: Bool
    let viewModel: RecordSaveSheetViewModel
    let dismiss: () -> Void
    
    var body: some View {
        Button(action: {
            viewModel.save()
            dismiss()
        }) {
            Text("저장")
                .font(.headline.bold())
                .foregroundColor(isDisabled ? DesignSystem.Color.Gray_Text2 : DesignSystem.Color.Gray_white)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(isDisabled ? DesignSystem.Color.Gray_Button2 : DesignSystem.Color.Prime2)
                .cornerRadius(12)
        }
        .disabled(isDisabled)
        .padding(.top, 30)
    }
}


