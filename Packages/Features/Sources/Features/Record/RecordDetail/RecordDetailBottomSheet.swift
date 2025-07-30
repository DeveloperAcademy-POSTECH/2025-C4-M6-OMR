//
//  RecordDetailBottomSheet.swift
//  Features
//
//  Created by Henry on 7/19/25.
//

import SwiftUI
import PhotosUI
import Domain
import DesignSystem


public struct RecordDetailBottomSheet: View {
    @StateObject private var viewModel: RecordDetailViewModel
    
    // 1) 포커스 상태 열거형
    private enum Field { case title }
    
    // 2) 부모 레벨 @FocusState
    @FocusState private var focusedField: Field?
    
    // dismiss 콜백 추가
      private let onDismiss: (() -> Void)?
    
    @State private var currentDetent: PresentationDetent = .fraction(0.45)
    
    private var isExpanded: Bool {
        currentDetent == .large
    }
    
    // MapView에서 데이터 주입을 위해 사용
    // MyRecordView에서 데이터 주입을 위해
    public init(viewModel: RecordDetailViewModel) {
           _viewModel = StateObject(wrappedValue: viewModel)
           self.onDismiss = nil
       }
    
    // onDismiss 콜백을 받는 새로운 이니셜라이저
       public init(viewModel: RecordDetailViewModel, onDismiss: (() -> Void)? = nil) {
           _viewModel = StateObject(wrappedValue: viewModel)
           self.onDismiss = onDismiss
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
            .onTapGesture {
                focusedField = nil
            }
        }
        .presentationDetents([.fraction(0.45), .large], selection: $currentDetent)
        .presentationDragIndicator(.visible)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: viewModel.isEditing) { _, isNowEditing in
            if isNowEditing {
                DispatchQueue.main.async {
                    focusedField = .title
                }
            } else {
                focusedField = nil
            }
        }
        .onChange(of: currentDetent) { _, newDetent in
            guard newDetent != .large, viewModel.isEditing else { return }
            viewModel.saveButtonTapped()
        }
        .onDisappear {
                    // 뷰가 사라질 때 콜백 호출
                    onDismiss?()
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
                    date: detail.date,
                    location: viewModel.detail?.location ?? ""
                )
                .focused($focusedField, equals: .title)
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
                DesignSystemAssets.image(named: "MainFlower")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 17, height: 17)
                    .clipped()
                Text(flowerName)
                    .font(.headline)
                Text(flowerMeaning)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Color.Prime2)
            }
            .padding(.all, 8)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Color.Prime5)
            .cornerRadius(12)
        }
    }
    
    private struct RecordInfoView: View {
        @Binding var title: String
        let originalTitle: String
        let isEditing: Bool
        let date: String
        let location: String

        var body: some View {
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    if isEditing {
                        ZStack(alignment: .center) {
                            if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("\(location)에서")
                                    .font(DesignSystem.Font.LargeTitle.semibold)
                                    .foregroundColor(DesignSystem.Color.Gray_black.opacity(0.5))
                            }

                            TextField("", text: $title)
                                .font(DesignSystem.Font.LargeTitle.semibold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(DesignSystem.Color.Gray_black)
                        }
                    } else {
                        Text(title)
                            .font(DesignSystem.Font.LargeTitle.semibold)
                            .foregroundColor(DesignSystem.Color.Gray_black)
                    }
                }

                Text(date)
                    .font(DesignSystem.Font.Headline.regular)
                    .foregroundColor(DesignSystem.Color.Gray_02)
            }
        }
    }

    
    private struct EditButtonView: View {
        let onEdit: () -> Void
        let onDelete: () -> Void
        
        var body: some View {
            Menu {
                Button("수정", action: onEdit)
                Button(role: .destructive, action: onDelete) {
                    Text("삭제")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 30, height: 30)
                    .background(DesignSystem.Color.Gray_Button)
                    .foregroundColor(DesignSystem.Color.Gray_black.opacity(0.25))
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
                    .foregroundColor(isDisabled ? DesignSystem.Color.Gray_Text2 : DesignSystem.Color.Gray_white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(isDisabled ? DesignSystem.Color.Gray_Button2 : DesignSystem.Color.Prime2)
                    .cornerRadius(12)
            }
            .disabled(isDisabled)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Preview

#Preview {
    RecordDetailBottomSheet(viewModel: RecordDetailViewModel())
}
