//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import SwiftUI
import DesignSystem

struct FlowerSelectionBottomSheet: View {
    @StateObject var viewModel: FlowerSelectionViewModel

    var body: some View {
        VStack(alignment: .center) {
            titleView
            flowerListView
        }
        .padding(.top, 16)
    }
}

// MARK: - Subviews
private extension FlowerSelectionBottomSheet {
    var titleView: some View {
        Text("꽃 선택")
            .font(DesignSystem.Font.Title1.semibold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.top, 2)
            .padding(.bottom, 12)
    }

    var flowerListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.flowers, id: \.id) { flower in
                    SelectableFlowerCard(
                        flower: flower,
                        isSelected: viewModel.selectedFlower?.id == flower.id,
                        action: { viewModel.selectFlower(flower) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - SelectableFlowerCard
private struct SelectableFlowerCard: View {
    let flower: FlowerModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        FlowerCardView(
            flower: flower,
            isSelected: isSelected
        )
        .onTapGesture(perform: action)
    }
}
