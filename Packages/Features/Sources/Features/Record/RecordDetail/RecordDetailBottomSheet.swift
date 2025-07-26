//
//  RecordDetailBottomSheet.swift
//  Features
//
//  Created by Henry on 7/19/25.
//

import SwiftUI
import PhotosUI
import Domain

public struct RecordDetailBottomSheet: View {
    @StateObject private var viewModel: RecordDetailViewModel
    @State private var currentDetent: PresentationDetent = .fraction(0.45)
    
    private var isExpanded: Bool {
        currentDetent == .large
    }
    
    // MapView에서 데이터 주입을 위해 사용
    // MyRecordView에서 데이터 주입을 위해
    public init(viewModel: RecordDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 14) {
                    topContent
                    
                    ImageCarouselView(
                        viewModel: viewModel,
                        isExpanded: isExpanded,
                        isEditing: viewModel.isEditing
                    )
                    
                    Spacer()
                    
                    bottomButton
                }
                .padding(.top, 34)
                .frame(minHeight: geometry.size.height)
            }
        }
        .presentationDetents([.fraction(0.45), .large], selection: $currentDetent)
        .presentationDragIndicator(.visible)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: currentDetent) { _, newDetent in
            guard newDetent != .large, viewModel.isEditing else { return }
                viewModel.saveButtonTapped()
        }
    }
    
    // MARK: - Composed Subviews
    
    @ViewBuilder
    private var topContent: some View {
        if let detail = viewModel.detail {
            VStack(spacing: 28) {
                RecordDetailHeaderView(
                    flowerName: detail.flowerName,
                    flowerMeaning: detail.flowerMeaning
                )
                
                RecordInfoView(
                    title: Binding(
                        get: { viewModel.detail?.title ?? "" },
                        set: { viewModel.detail?.title = $0 }
                    ),
                    originalTitle: viewModel.detail?.title ?? "",
                    isEditing: viewModel.isEditing,
                    date: detail.date
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var bottomButton: some View {
        if isExpanded {
            if viewModel.isEditing {
                SaveButtonView(isDisabled: viewModel.isSaveButtonDisabled) {
                    viewModel.saveButtonTapped()
                    DispatchQueue.main.async {
                        currentDetent = .fraction(0.45)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack {
                    Spacer()
                    
                    EditButtonView(
                        onEdit: {
                            viewModel.editButtonTapped()
                        },
                        onDelete: {
                            viewModel.deleteButtonTapped()
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Subviews
    
    private struct RecordDetailHeaderView: View {
        let flowerName: String
        let flowerMeaning: String
        
        var body: some View {
            HStack(spacing: 8) {
                Text(flowerName)
                    .font(.headline)
                Text(flowerMeaning)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.43, green: 0.65, blue: 0.96))
            }
            .padding(.all, 8)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.9, green: 0.94, blue: 1).opacity(0.47))
            .cornerRadius(8)
        }
    }
    
    private struct RecordInfoView: View {
        @Binding var title: String
        let originalTitle: String
        let isEditing: Bool
        let date: String
        
        @FocusState private var isTitleFieldFocused: Bool
        
        var body: some View {
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    if isEditing {
                        ZStack(alignment: .center) {
                            if title.isEmpty {
                                Text(originalTitle)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15).opacity(0.5))
                            }
                            TextField("", text: $title)
                                .font(.system(size: 20, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .focused($isTitleFieldFocused)
                        }
                    } else {
                        Text(title)
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
                
                Text(date)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.57, green: 0.63, blue: 0.71))
            }
            .onChange(of: isEditing) { _, isNowEditing in
                if isNowEditing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isTitleFieldFocused = true
                    }
                }
            }
        }
    }
}

private struct EditButtonView: View {
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Menu {
            Button("기록 수정", action: onEdit)
            Button(role: .destructive, action: onDelete) {
                Text("삭제")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 32, height: 32)
                .background(Color(red: 0.45, green: 0.51, blue: 0.59).opacity(0.16))
                .foregroundColor(Color(red: 0.45, green: 0.51, blue: 0.59))
                .cornerRadius(99)
        }
    }
}

private struct SaveButtonView: View {
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("수정 완료")
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(isDisabled ? Color.gray : Color(red: 0.43, green: 0.65, blue: 0.96))
                .cornerRadius(12)
        }
        .disabled(isDisabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Preview

#Preview {
    RecordDetailBottomSheet(viewModel: RecordDetailViewModel())
}
