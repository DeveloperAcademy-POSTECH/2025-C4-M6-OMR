//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/23/25.
//

import SwiftUI

struct FlowerSelectionBottomSheet: View {
    @StateObject var viewModel: FlowerSelectionViewModel

    var body: some View {
        VStack(alignment: .center) {
            Text("꽃 선택")
              .font(
                Font.custom("Pretendard", size: 20)
                  .weight(.semibold)
              )
              .multilineTextAlignment(.center)
              .padding(.horizontal, 20)
              .padding(.top, 2)
              .padding(.bottom, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.markers, id: \.id) { marker in
                        FlowerCardView(
                            marker: marker,
                            isSelected: viewModel.selectedMarker?.id == marker.id // ✅ 선택된 마커인지 확인
                        )
                        .onTapGesture {
                            viewModel.selectMarker(marker)
                        }
                    }
                }
                .padding(.horizontal)
            }

        }
        .padding(.top, 16)
    }
}
