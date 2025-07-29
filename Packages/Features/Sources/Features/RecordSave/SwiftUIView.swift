//
//  SwiftUIView.swift
//  Features
//
//  Created by Henry on 7/21/25.
//

import SwiftUI

// Record가 .sheet(item:)에서 사용될 수 있도록 Identifiable 프로토콜을 채택합니다.
extension Record: Identifiable {}

public struct SwiftUIView: View {
    @State private var isShowingSaveSheet = false
    @State private var savedRecords: [Record] = []
    @State private var selectedRecord: Record?

    public init() { }

    public var body: some View {
        NavigationStack {
            VStack {
                if savedRecords.isEmpty {
                    Text("아직 저장된 기록이 없습니다.\n '+' 버튼을 눌러 새 기록을 추가해보세요.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(savedRecords) { record in
                            Button(action: {
                                self.selectedRecord = record
                            }) {
                                HStack {
                                    Text(record.flower.name)
                                    Spacer()
                                    Text("사진 \(record.imageFileNames.count)장")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("내 기록")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add New Record") {
                        isShowingSaveSheet = true
                    }
                }
            }
            .sheet(isPresented: $isShowingSaveSheet) {
                let viewModel = RecordSaveSheetViewModel(
                    info: RecordSaveSheetInfo(
                        flower: ARFlower(name: "Test Flower", modelName: "test", floriography: "Test", thumbnail: "test", thumbnailLarge: ""),
                        location: .init(),
                        address: "Test Address"
                    ),
                    onSave: { finalRecord in
                        // 여기서는 실제 저장을 하지 않으므로 비워둡니다.
                        // 필요하다면 savedRecords에 추가하는 로직을 구현할 수 있습니다.
                    }
                )
                RecordSaveSheetView(
                    viewModel: viewModel,
                    onCancelPlacement: {
                        isShowingSaveSheet = false
                    }
                )
            }
//            .sheet(item: $selectedRecord) { record in
//                RecordDetailBottomSheet(
//                    viewModel: RecordDetailViewModel(record: record)
//                )
//            }
        }
    }
}
