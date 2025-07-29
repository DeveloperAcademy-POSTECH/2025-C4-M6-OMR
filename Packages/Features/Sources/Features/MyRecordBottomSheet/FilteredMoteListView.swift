//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/22/25.
//

import SwiftUI

struct FilteredMoteListView: View {
    let filteredMotes: [Mote]
    let currentAddress: String
    let onRecordTap: (UUID) -> Void


    var body: some View {
        if !filteredMotes.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(currentAddress.isEmpty ? "주소 없음" : currentAddress)에서 심은 꽃")
                    .font(
                        Font.custom("Pretendard", size: 18)
                            .weight(.bold)
                    )
                    .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                ForEach(filteredMotes, id: \.id) { mote in
                    Button {
                        onRecordTap(mote.id)
                                       } label: {
                                           MoteItemView(mote: mote)
                                       }
                                       .buttonStyle(.plain)
                }
            }
            .padding(.bottom,36)
        }
    }
}

