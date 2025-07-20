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
    
    public init(viewModel: RecordDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 14) {
                    
                    VStack(spacing: 28) {
                        RecordDetailHeaderView(
                            flowerName: viewModel.flowerName,
                            flowerMeaning: viewModel.flowerMeaning
                        )
                        
                        RecordInfoView(
                            title: $viewModel.title,
                            isEditing: viewModel.isEditing,
                            date: viewModel.date
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    ImageCarouselView(
                        viewModel: viewModel,
                        isExpanded: isExpanded,
                        isEditing: viewModel.isEditing
                    )
                    
                    Spacer()
                    
                    if isExpanded {
                        EditButtonView(isEditing: viewModel.isEditing) {
                            if viewModel.isEditing {
                                viewModel.saveButtonTapped()
                            } else {
                                viewModel.editButtonTapped()
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.top, 34)
                .frame(minHeight: geometry.size.height)
            }
        }
        .presentationDetents([.fraction(0.45), .large], selection: $currentDetent)
        .presentationDragIndicator(.visible)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: currentDetent) { _, newDetent in
            if newDetent != .large, viewModel.isEditing {
                viewModel.saveButtonTapped()
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
        let isEditing: Bool
        let date: String
        
        @FocusState private var isTitleFieldFocused: Bool
        
        var body: some View {
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    if isEditing {
                        TextField("", text: $title)
                            .font(.system(size: 20, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .focused($isTitleFieldFocused)
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
    let isEditing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            LabelView(isEditing: isEditing)
        }
        .buttonStyle(.plain)
        .padding(.bottom)
    }
    
    private struct LabelView: View {
        let isEditing: Bool
        
        var body: some View {
            let backgroundColor = isEditing
            ? Color(red: 0.43, green: 0.65, blue: 0.96)
            : Color(red: 0.94, green: 0.95, blue: 0.96)
            
            let textColor = isEditing
            ? Color.white
            : Color(red: 0.56, green: 0.56, blue: 0.56)
            
            return Text(isEditing ? "수정완료" : "수정")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(textColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .cornerRadius(99)
        }
    }
}

// MARK: - Preview

#Preview {
    RecordDetailBottomSheet(viewModel: RecordDetailViewModel())
}
