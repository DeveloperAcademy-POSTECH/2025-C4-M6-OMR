//
//  ARTopBarView.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import SwiftUI
import DesignSystem

struct ARTopBarView: View {
    let onClose: () -> Void

    var body: some View {
        HStack {
            Spacer()
            ARCancelButton(action: onClose)
        }
    }
}
