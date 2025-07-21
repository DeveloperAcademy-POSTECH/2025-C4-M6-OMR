import SwiftUI
import CoreLocation
import MapKit

struct MyRecordBottomSheet: View {
    @Binding var selectedDetent: PresentationDetent
    @StateObject private var viewModel = MyRecordBottomSheetViewModel()
    @EnvironmentObject private var locationManager: LocationManager

    @State private var isShowingFullList = false  // 전체 기록 리스트 시트 상태

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                ProgressView("로딩 중...")
            } else if let error = viewModel.errorMessage {
                Text("❗️오류: \(error)")
                    .foregroundColor(.red)
            } else {
                contentView()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            updateMotes(for: selectedDetent)
        }
        .onChange(of: selectedDetent) { _, newValue in
            updateMotes(for: newValue)
        }
    }

    @ViewBuilder
    private func contentView() -> some View {
        switch selectedDetent {
        case .fraction(0.2):
            VStack{
                Text("내 꽃")
                    .font(.headline)
                Text("🌼 총 \(viewModel.allMotes.count)개의 기록이 있어요!")
                    .font(.title3)
                    .bold()
            }
            
        case .fraction(1.0):
            VStack(alignment: .leading, spacing: 12) {
                // 상단에 닫기 버튼 포함 HStack
               
                HStack {
                    Spacer()
                    Button {
                        selectedDetent = .fraction(0.2)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                Text("내 꽃")
                    .font(.headline)
                
                Button(action: {
                    // MyRecordView로 진입
                }) {
                    HStack {
                        Text("전체 기록은 \(viewModel.allMotes.count)개 있습니다.")
                            .foregroundColor(.blue)
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }

                // filteredMotes가 있을 때만 표시
                if !viewModel.filteredMotes.isEmpty {
                    Text("📍 \(locationManager.currentAddress)에서 심은 꽃")
                        .font(.headline)

                    ScrollView {
                        ForEach(viewModel.filteredMotes.indices, id: \.self) { index in
                            let mote = viewModel.filteredMotes[index]
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📒 \(mote.title)")
                                    .font(.headline)
                                Text("🗺️ \(mote.address)")
                                    .font(.caption)
                                Divider()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                if let currentLocation = locationManager.currentLocation {
                    let identifiableLocation = IdentifiableLocation(location: currentLocation)

                    Map(initialPosition: .region(
                        MKCoordinateRegion(
                            center: identifiableLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )) {
                        Marker("내 위치", coordinate: identifiableLocation.coordinate)
                            .tint(.blue)
                    }
                    .mapStyle(.standard)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                    .cornerRadius(12)
                }
            }

        default:
            EmptyView()
        }
    }


    private func updateMotes(for detent: PresentationDetent) {
        switch detent {
        case .fraction(0.2):
            viewModel.loadAllMotes()
        case .fraction(1.0):
            if let location = locationManager.currentLocation {
                viewModel.loadAllMotes()
                viewModel.filterMotesByLocation(currentLocation: location)
            } else {
                viewModel.errorMessage = "현재 위치 정보를 가져올 수 없습니다"
            }
        default:
            break
        }
    }

    private func detentLabel(for detent: PresentationDetent) -> String {
        switch detent {
        case .fraction(0.2): return "Small"
        case .fraction(1): return "Large"
        default: return "Other"
        }
    }
}

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let location: CLLocation

    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }
}
