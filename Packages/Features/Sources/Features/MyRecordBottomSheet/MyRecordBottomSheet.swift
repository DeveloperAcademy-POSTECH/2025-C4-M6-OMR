import CoreLocation
import DesignSystem
import SwiftUI

struct MyRecordBottomSheet: View {
    @Binding var selectedPosition: SheetPosition
    @ObservedObject var viewModel: MyRecordBottomSheetViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Drag Indicator
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 36, height: 5)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading) {
                Text("내 꽃")
                    .font(DesignSystem.Font.Title1.semibold)
                    .padding(.bottom, 4)

                Text("\(viewModel.allMotes.count)개의 꽃")
                    .font(DesignSystem.Font.Body.regular)
                    .foregroundColor(
                        DesignSystem.Color.Gray_03
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)

            Spacer(minLength: 0)
        }
        .background(Color.white)

        .cornerRadius(10)
        .onAppear {
            viewModel.loadAllMotes()
        }

    }

}

