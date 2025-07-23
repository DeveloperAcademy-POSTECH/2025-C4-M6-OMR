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
    
    public init(viewModel: RecordSaveSheetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            RecordSaveHeaderView { dismiss() }
            
            if let detail = viewModel.detail {
                SelectedFlowerCardView(
                    flowerName: detail.name,
                    flowerMeaning: detail.meaning,
                    flowerImageName: detail.imageName
                )
                .padding(.bottom, 30)
            }
            
            PhotoSelectionView(viewModel: viewModel)
                .padding(.bottom, 20)
            
            SaveButtonView(isDisabled: viewModel.isSaveButtonDisabled) {
                viewModel.saveImages()
            }
            
            Spacer()
        }
        .presentationDetents([.fraction(0.8), .large])
        .interactiveDismissDisabled(true)
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Subviews

private struct RecordSaveHeaderView: View {
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.45, green: 0.51, blue: 0.59).opacity(0.16))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15).opacity(0.25))
                    }
                    .padding(.trailing, 20)
                }
            }
            
            Text("꽃 심기 완료!")
                .font(DesignSystem.Font.custom(size: 18, weight: .bold))
            
            Text("함께 기억할 사진을 저장해주세요.")
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
                DesignSystemAssets.image(named: "flower_icon")
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text(flowerName)
                    .font(DesignSystem.Font.custom(size: 16, weight: .medium))
            }
            
            Text(flowerMeaning)
                .font(DesignSystem.Font.custom(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.43, green: 0.65, blue: 0.96))
            
            DesignSystemAssets.image(named: flowerImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
        }
        .padding(.top, 14)
        .padding(.bottom, 30)
        .padding(.horizontal, 45)
        .background(Color(red: 0.94, green: 0.96, blue: 1))
        .cornerRadius(20)
    }
}

private struct SaveButtonView: View {
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("저장")
                .font(.headline.bold())
                .foregroundColor(isDisabled ? Color(red: 0.56, green: 0.56, blue: 0.56) : Color.white)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(isDisabled ? Color(red: 0.88, green: 0.9, blue: 0.93).opacity(0.39) : Color(red: 0.43, green: 0.65, blue: 0.96))
                .cornerRadius(12)
        }
        .disabled(isDisabled)
        .padding(.top, 30)
        .padding(.horizontal, 20)
    }
}
        

