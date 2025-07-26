//
//  ARTopBarView.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import SwiftUI

struct ARTopBarView: View {
    let onClose: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }
}
