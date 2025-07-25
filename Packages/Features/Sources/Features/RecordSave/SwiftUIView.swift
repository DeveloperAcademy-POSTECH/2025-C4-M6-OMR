//
//  SwiftUIView.swift
//  Features
//
//  Created by Henry on 7/21/25.
//

import SwiftUI

public struct SwiftUIView: View {
    @State private var isShowingSave = false
    
    public init() { }

    public var body: some View {
        VStack {
            Button("꽃 저장 모달 열기") {
                isShowingSave = true
            }
        }
        .sheet(isPresented: $isShowingSave) {
            RecordSaveSheetView(
                viewModel: RecordSaveSheetViewModel(),
                onSave: { newRecord in
                    print("✅ Record saved in temporary view: \(newRecord)")
                }
            )
        }
    }
}
