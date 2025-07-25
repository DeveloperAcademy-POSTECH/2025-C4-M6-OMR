//
//  SelectedPhotoView.swift
//  Features
//
//  Created by Henry on 7/24/25.
//

import SwiftUI

public struct SelectedPhotoView: View {
    let image: UIImage
    let deleteAction: () -> Void
    let size: CGFloat

    public var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipped()
            .overlay(alignment: .topTrailing) {
                Button(action: deleteAction) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.6))
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .padding(4)
            }
    }
}
