import SwiftUI
import PhotosUI
import Domain

public struct RecordDetailBottomSheet: View {
    @StateObject private var viewModel: RecordDetailViewModel
    @State private var currentDetent: PresentationDetent = .fraction(0.45)

    public init(viewModel: RecordDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 14) {
        
            VStack(spacing: 28) {
                RecordDetailHeaderView(
                    flowerName: viewModel.flowerName,
                    flowerMeaning: viewModel.flowerMeaning
                )
                
                RecordInfoView(
                    location: viewModel.location,
                    date: viewModel.date
                )
            }
            .padding(.horizontal, 20)

            ImageCarouselView(
                viewModel: viewModel,
                isExpanded: currentDetent == .large
            )
            
            Spacer()
        }
        .padding(.top, 34)
        .presentationDetents([.fraction(0.45), .large], selection: $currentDetent)
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Header

private struct RecordDetailHeaderView: View {
    let flowerName: String
    let flowerMeaning: String

    var body: some View {
        HStack(spacing: 8) {
            Text(flowerName)
                .font(.headline)
                .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))

            Text(flowerMeaning)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.43, green: 0.65, blue: 0.96))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.9, green: 0.94, blue: 1).opacity(0.47))
        .cornerRadius(8)
    }
}

// MARK: - Info

private struct RecordInfoView: View {
    let location: String
    let date: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(location)에서")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))

            Text(date)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.57, green: 0.63, blue: 0.71))
        }
    }
}

// MARK: - Preview

#Preview {
    RecordDetailBottomSheet(viewModel: RecordDetailViewModel())
}
