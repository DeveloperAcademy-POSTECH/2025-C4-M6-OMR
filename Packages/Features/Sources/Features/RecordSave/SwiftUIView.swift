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
                RecordSaveSheetView(
                    viewModel: RecordSaveSheetViewModel(),
                    onSave: { newRecord in
                        savedRecords.append(newRecord)
                    }
                )
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailBottomSheet(
                    viewModel: RecordDetailViewModel(record: record)
                )
            }
        }
    }
}
