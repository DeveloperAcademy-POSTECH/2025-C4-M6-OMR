import SwiftUI
import Photos

struct CustomAlbumView: View {
    @ObservedObject var viewModel: RecordSaveSheetViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLimitAlert = false  // ← 추가
    
    private let columns = 3
    private let spacing: CGFloat = 2
    private var gridItems: [GridItem] {
        Array(repeating: .init(.flexible(), spacing: spacing), count: columns)
    }
    private var cellSize: CGFloat {
        let totalSpacing = spacing * CGFloat(columns - 1)
        return (UIScreen.main.bounds.width - totalSpacing) / CGFloat(columns)
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
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            viewModel.prepareForAllPhotos()
        }
        .alert("최대 \(viewModel.maxImageCount)장까지 기록할 수 있어요", isPresented: $showLimitAlert) {
            Button("확인", role: .cancel) { }
        }
    }
    
    private var customHeader: some View {
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                }
                
                Spacer()
                
                if !viewModel.selectedAssets.isEmpty {
                    Button(action: {
                        viewModel.finalizeAssetSelection()
                        dismiss()
                    }) {
                        Text("\(viewModel.selectedAssets.count) 선택")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(red: 0.43, green: 0.65, blue: 0.96))
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
        .background(Color.white)
    }
}
