//
//  MyRecordView.swift
//  Features
//
//  Created by Jimin on 7/20/25.
//

import SwiftUI
import DesignSystem
import SwiftUI
import Dependencies

struct MyRecordView: View {
    @StateObject private var viewModel: MyRecordViewModel
    @EnvironmentObject private var nav: NavigationViewModel

    @State private var selectedRecordID: IdentifiableUUID? = nil

    public init() {
        // View가 생성되는 시점의 의존성을 가져옵니다.
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        
        // 가져온 의존성을 ViewModel에 직접 주입합니다.
        self._viewModel = StateObject(
            wrappedValue:
                MyRecordViewModel(
                fetchMyRecordsUseCase: fetchMyRecordsUseCase
            )
        )
    }
    
    
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
                .padding(.horizontal, 20)

                Text("전체")
                    .font(DesignSystem.Font.NavigationTitle.bold)
                    .foregroundColor(DesignSystem.Color.Gray_black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)

                RecordList(
                    records: viewModel.records,
                    onRecordTap: { id in
                        selectedRecordID = IdentifiableUUID(id: id)
                    }
                )
                .padding(.horizontal, 20)
            }
            .background(DesignSystem.Color.BgScreen)
            .navigationBarHidden(true)
            .sheet(item: $selectedRecordID) { identifiableID in
                @Dependency(\.fetchRecordDetailUseCase) var fetchRecordDetailUseCase
                
                RecordDetailBottomSheet(
                    viewModel: RecordDetailViewModel(
                        id: identifiableID.id,
                        fetchRecordDetailUseCase: fetchRecordDetailUseCase
                    )

                )
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
