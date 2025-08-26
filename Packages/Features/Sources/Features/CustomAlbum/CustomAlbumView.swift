import SwiftUI
import Photos
import DesignSystem

struct CustomAlbumView: View {
    @ObservedObject var viewModel: CustomAlbumViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLimitAlert = false
    
    @State private var visibleIndices: IndexSet = []
    
    private let columns = 3
    private let spacing: CGFloat = 2
    private var gridItems: [GridItem] {
        Array(repeating: .init(.flexible(), spacing: spacing), count: columns)
    }
    private var cellSize: CGFloat {
        let totalSpacing = spacing * CGFloat(columns - 1)
        return (UIScreen.main.bounds.width - totalSpacing) / CGFloat(columns)
    }
    
    private var targetThumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: cellSize * scale, height: cellSize * scale)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customHeader
            
            ScrollView {
                if let assetsResult = viewModel.allPhotoAssetsResult {
                    LazyVGrid(columns: gridItems, spacing: spacing) {
                        ForEach(0..<assetsResult.count, id: \.self) { index in
                            let asset = assetsResult.object(at: index)
                            
                            AlbumGridItemView(
                                asset: asset,
                                isSelected: viewModel.selectedAssets.contains(asset),
                                selectedIndex: viewModel.selectedAssets.firstIndex(of: asset),
                                viewModel: viewModel,
                                cellSize: cellSize
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // 이미 선택된 건 토글
                                if viewModel.selectedAssets.contains(asset) {
                                    viewModel.toggleAssetSelection(asset)
                                }
                                // 새로 선택하려는데 4장 초과면 alert
                                else if viewModel.selectedAssets.count >= viewModel.maxImageCount {
                                    showLimitAlert = true
                                }
                                // 그 외엔 정상 선택
                                else {
                                    viewModel.toggleAssetSelection(asset)
                                }
                            }
                            .onAppear {
                                visibleIndices.insert(index)
                            }
                            .onDisappear {
                                visibleIndices.remove(index)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            // ◀️ View가 나타날 때, 계산된 셀 크기로 초기 캐싱을 요청합니다.
            viewModel.startInitialCaching(targetSize: targetThumbnailSize)
        }
        .alert("최대 \(viewModel.maxImageCount)장까지 선택할 수 있어요", isPresented: $showLimitAlert) {
            Button("확인", role: .cancel) { }
        }
        .onChange(of: visibleIndices) { _, newIndices in
            // ◀️ 스크롤 시 보이는 인덱스가 바뀔 때마다 셀 크기와 함께 캐싱 업데이트를 요청합니다.
            viewModel.updateCachedAssets(visibleIndices: newIndices, targetSize: targetThumbnailSize)
        }
    }
    
    private var customHeader: some View {
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(DesignSystem.Color.Gray_Text2)

                }
                .padding(.vertical, 18)
                
                Spacer()
                
                if !viewModel.selectedAssets.isEmpty {
                    Button(action: {
                        viewModel.finalizeSelection()
                        dismiss()
                    }) {
                        Text("\(viewModel.selectedAssets.count) 선택")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(DesignSystem.Color.Prime2)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            
            Text("사진")
                .font(.headline.bold())
        }
        .padding(.vertical, 10)
        .frame(height: 56)
        .background(DesignSystem.Color.Gray_white)
    }
}
