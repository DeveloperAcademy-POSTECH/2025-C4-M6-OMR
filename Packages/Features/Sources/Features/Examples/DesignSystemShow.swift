//
//  DesignSystemShow.swift
//  Features
//
//  Created by Jimin on 7/23/25.
//

import SwiftUI
import DesignSystem

struct TypographyPreviewView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - Title 1
                    fontSection(
                        title: "Title 1",
                        items: [
                            FontItem(name: "Semibold · 24", font: DesignSystem.Font.Title1.semibold)
                        ]
                    )
                    
                    // MARK: - Title 2
                    fontSection(
                        title: "Title 2",
                        items: [
                            FontItem(name: "Semibold · 18", font: DesignSystem.Font.Title2.semibold),
                            FontItem(name: "Bold · 18", font: DesignSystem.Font.Title2.bold)
                        ]
                    )
                    
                    // MARK: - Headline
                    fontSection(
                        title: "Headline",
                        items: [
                            FontItem(name: "Semibold · 14", font: DesignSystem.Font.Headline.semibold),
                            FontItem(name: "Medium · 14", font: DesignSystem.Font.Headline.medium),
                            FontItem(name: "Regular · 14", font: DesignSystem.Font.Headline.regular)
                        ]
                    )
                    
                    // MARK: - Title 3
                    fontSection(
                        title: "Title 3",
                        items: [
                            FontItem(name: "Semibold · 16", font: DesignSystem.Font.Title3.semibold),
                            FontItem(name: "Medium · 16", font: DesignSystem.Font.Title3.medium)
                        ]
                    )
                    
                    // MARK: - Large Title
                    fontSection(
                        title: "Large Title",
                        items: [
                            FontItem(name: "Semibold · 20", font: DesignSystem.Font.LargeTitle.semibold)
                        ]
                    )
                    
                    // MARK: - Body
                    fontSection(
                        title: "Body",
                        items: [
                            FontItem(name: "Regular · 12", font: DesignSystem.Font.Body.regular)
                        ]
                    )
                    
                    // MARK: - Navigation Title
                    fontSection(
                        title: "Navigation Title",
                        items: [
                            FontItem(name: "Bold · 28", font: DesignSystem.Font.NavigationTitle.bold)
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
    private func fontSection(title: String, items: [FontItem]) -> some View {
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
                ForEach(items, id: \.name) { item in
                    fontPreviewRow(item: item)
                }
            }
        }
    }
    
    @ViewBuilder
    private func fontPreviewRow(item: FontItem) -> some View {
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

struct FontItem {
    let name: String
    let font: Font
}

// MARK: - Preview

struct TypographyPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        TypographyPreviewView()
            .preferredColorScheme(.light)
        
        TypographyPreviewView()
            .preferredColorScheme(.dark)
    }
}

