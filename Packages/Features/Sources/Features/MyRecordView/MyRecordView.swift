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
                            .font(.system(size: 24).weight(.semibold))
                            .foregroundColor(DesignSystem.Color.Gray_02)
                    }
                    Spacer()
                }
                .padding(.top, 15)

                Text("전체")
                    .font(DesignSystem.Font.NavigationTitle.bold)
                    .foregroundColor(DesignSystem.Color.Gray_black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                    .padding(.bottom, 20)


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
