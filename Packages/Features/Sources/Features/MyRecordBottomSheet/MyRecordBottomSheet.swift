import SwiftUI
import CoreLocation

struct MyRecordBottomSheet: View {
    @Binding var selectedPosition: SheetPosition
    @StateObject private var viewModel = MyRecordBottomSheetViewModel()
    var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Drag Indicator
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)

            if viewModel.isLoading {
                ProgressView("로딩 중...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let error = viewModel.errorMessage {
                Text("❗️오류: \(error)")
                    .foregroundColor(.red)
            } else {
                VStack {
                    Text("내 꽃")
                        .font(.headline)
                    Text("🌼 총 \(viewModel.allMotes.count)개의 기록이 있어요!")
                        .font(.title3)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .onAppear {
            viewModel.loadAllMotes()
        }
    }
}
