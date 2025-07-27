//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import DesignSystem
import SwiftUI

struct FlowerSelectionBottomSheet: View {
    @StateObject var viewModel: FlowerSelectionViewModel

    var body: some View {
        VStack(alignment: .center) {
            titleView
            flowerListView
        }
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
        .padding(.top, 16)
    }
}

// MARK: - Subviews
extension FlowerSelectionBottomSheet {
    fileprivate var titleView: some View {
        Text("꽃 선택")
            .font(DesignSystem.Font.Title1.semibold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.top, 2)
            .padding(.bottom, 12)
    }

    fileprivate var flowerListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.flowers, id: \.id) { flower in
                    SelectableFlowerCard(
                        flower: flower,
                        isSelected: viewModel.selectedFlower?.id == flower.id,
                        onSelect: {
                            viewModel.selectFlower(flower)
                        }
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
    let onSelect: () -> Void

    var body: some View {
        FlowerCardView(
            flower: flower,
            isSelected: isSelected
        )
        .onTapGesture(perform: onSelect)
    }
}
