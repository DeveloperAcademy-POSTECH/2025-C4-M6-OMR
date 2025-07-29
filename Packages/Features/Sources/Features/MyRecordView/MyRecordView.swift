//
//  MyRecordView.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI
import DesignSystem

struct MyRecordView: View {
    @StateObject private var viewModel = MyRecordViewModel()
    @EnvironmentObject private var nav: NavigationViewModel

    @State private var selectedRecordID: IdentifiableUUID? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        if !nav.path.isEmpty {
                            nav.path.removeLast()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 16)

                Text("전체")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                    .frame(height: 20)

                RecordList(
                    records: viewModel.records,
                    onRecordTap: { id in
                        selectedRecordID = IdentifiableUUID(id: id)
                    }
                )
            }
            .padding(.horizontal, 20)
            .navigationBarHidden(true)
            .sheet(item: $selectedRecordID) { identifiableID in
                RecordDetailBottomSheet(viewModel: RecordDetailViewModel(id: identifiableID.id))
            }
        }
    }
}

struct IdentifiableUUID: Identifiable, Equatable {
    let id: UUID
}



#Preview {
    MyRecordView()
}
