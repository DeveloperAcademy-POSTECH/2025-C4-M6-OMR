//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import SwiftUI

struct FlowerSelectionPreviewContainer: View {
    @StateObject var viewModel = FlowerSelectionViewModel()
    @State private var isPresented = true

    var body: some View {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                FlowerSelectionBottomSheet(viewModel: viewModel)
                    .presentationDetents([.height(200)])
                    .presentationDragIndicator(.visible) // 드래그 인디케이터는 표시
            }
    }
}

#Preview {
    FlowerSelectionPreviewContainer()
}
