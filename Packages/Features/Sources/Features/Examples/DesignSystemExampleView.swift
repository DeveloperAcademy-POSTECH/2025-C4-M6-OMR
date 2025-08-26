import SwiftUI
import DesignSystem

struct DesignSystemShow: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - Title 1
                    fontSection(
                        title: "Title 1",
                        items: [
                            FontPreviewItem(name: "Semibold · 24/140", font: DesignSystem.Font.Title1.semibold)
                        ]
                    )
                    
                    // MARK: - Title 2
                    fontSection(
                        title: "Title 2",
                        items: [
                            FontPreviewItem(name: "Semibold · 18/Auto", font: DesignSystem.Font.Title2.semibold),
                            FontPreviewItem(name: "Bold · 18/140", font: DesignSystem.Font.Title2.bold)
                        ]
                    )
                    
                    // MARK: - Headline
                    fontSection(
                        title: "Headline",
                        items: [
                            FontPreviewItem(name: "Semibold · 14/Auto", font: DesignSystem.Font.Headline.semibold),
                            FontPreviewItem(name: "Medium · 14/150", font: DesignSystem.Font.Headline.medium),
                            FontPreviewItem(name: "Regular · 14/150", font: DesignSystem.Font.Headline.regular)
                        ]
                    )
                    
                    // MARK: - Title 3
                    fontSection(
                        title: "Title 3",
                        items: [
                            FontPreviewItem(name: "Semibold · 16/140", font: DesignSystem.Font.Title3.semibold),
                            FontPreviewItem(name: "Medium · 16/140", font: DesignSystem.Font.Title3.medium)
                        ]
                    )
                    
                    // MARK: - Large Title
                    fontSection(
                        title: "Large Title",
                        items: [
                            FontPreviewItem(name: "Semibold · 20/140", font: DesignSystem.Font.LargeTitle.semibold)
                        ]
                    )
                    
                    // MARK: - Body
                    fontSection(
                        title: "Body",
                        items: [
                            FontPreviewItem(name: "Regular · 12/Auto", font: DesignSystem.Font.Body.regular)
                        ]
                    )
                    
                    // MARK: - Navigation Title
                    fontSection(
                        title: "Navigation Title",
                        items: [
                            FontPreviewItem(name: "Bold · 28/140", font: DesignSystem.Font.NavigationTitle.bold)
                        ]
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Typography")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func fontSection(title: String, items: [FontPreviewItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 섹션 제목
            HStack {
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 폰트 아이템들
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    fontPreviewRow(item: item)
                }
            }
        }
    }
    
    @ViewBuilder
    private func fontPreviewRow(item: FontPreviewItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 샘플 텍스트
            HStack {
                Text("Ag")
                    .font(item.font)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // 폰트 정보
            Text(item.name)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.leading, 20)
    }
}

// MARK: - Supporting Types

struct FontPreviewItem {
    let name: String
    let font: SwiftUI.Font
}

// MARK: - Preview

#Preview {
    TypographyPreviewView()
}
