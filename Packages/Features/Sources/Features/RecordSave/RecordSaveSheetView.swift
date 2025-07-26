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
            
            ScrollView {
                VStack(spacing: 0) {
                    SelectedFlowerCardView(
                        flowerName: viewModel.flowerName,
                        flowerMeaning: viewModel.flowerMeaning,
                        flowerImageName: viewModel.flowerImageName
                    )
                    .padding(.bottom, 30)
                    
                    RecordFormView(
                        title: $viewModel.title,
                        description: $viewModel.description
                    )
                    .padding(.bottom, 20)
                    
                    PhotoSelectionView(viewModel: viewModel)
                        .padding(.bottom, 20)
                }
            }
            
            SaveButtonView(
                isDisabled: viewModel.isSaveButtonDisabled,
                viewModel: viewModel,
                dismiss: { dismiss() }
            )
            Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents([.large])
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

private struct RecordFormView: View {
    @Binding var title: String
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("제목")
                    .font(DesignSystem.Font.custom(size: 16, weight: .semibold))
                
                TextField("기록의 제목을 입력해주세요", text: $title)
                    .font(DesignSystem.Font.custom(size: 15, weight: .regular))
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("내용")
                    .font(DesignSystem.Font.custom(size: 16, weight: .semibold))
                
                TextEditor(text: $description)
                    .font(DesignSystem.Font.custom(size: 15, weight: .regular))
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
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
                .foregroundColor(isDisabled ? Color(red: 0.56, green: 0.56, blue: 0.56) : Color.white)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(isDisabled ? Color(red: 0.88, green: 0.9, blue: 0.93).opacity(0.39) : Color(red: 0.43, green: 0.65, blue: 0.96))
                .cornerRadius(12)
        }
        .disabled(isDisabled)
        .padding(.top, 30)
    }
}
        

