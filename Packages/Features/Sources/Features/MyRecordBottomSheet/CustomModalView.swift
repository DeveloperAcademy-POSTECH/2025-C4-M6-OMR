//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/24/25.
//

import SwiftUI
import CoreLocation
import DesignSystem
import MapKit
import SwiftUI
import Dependencies

// MARK: - Detent Enum

enum Detent {
    case large, low

    func offset(in geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let safeAreaTop = geometry.safeAreaInsets.top

        switch self {
        case .large:
            return safeAreaTop - 60
        case .low:
            return screenHeight * 0.90
        }
    }
}

// MARK: - Custom Modal View

struct CustomModalView: View {
    @Binding var sheetDetent: Detent
    @Binding var isSheetVisible: Bool
    @Binding var totalCount: Int

    @ObservedObject var locationManager: LocationManager
    @EnvironmentObject private var nav: NavigationViewModel

    let detentOffsets: (large: CGFloat, low: CGFloat)
    let bottomSafeArea: CGFloat

    @State private var dragTranslation: CGFloat = 0

    @State private var isAtTop: Bool = true
    @GestureState private var isDraggingGesture: Bool = false
    var isDragging: Bool { isDraggingGesture }
    @State private var isDraggingUp = false  // .low -> .large 전환 중
    @State private var isDraggingDown = false  // .large -> .low 전환 중

    @State private var selectedRecordID: IdentifiableUUID? = nil
    
    @StateObject private var viewModel: MyRecordBottomSheetViewModel
    public init(
        sheetDetent: Binding<Detent>,
        isSheetVisible: Binding<Bool>,
        totalCount: Binding<Int>,
        locationManager: LocationManager,
        detentOffsets: (large: CGFloat, low: CGFloat),
        bottomSafeArea: CGFloat
    ) {
        self._sheetDetent = sheetDetent
        self._isSheetVisible = isSheetVisible
        self._totalCount = totalCount
        self.locationManager = locationManager
        self.detentOffsets = detentOffsets
        self.bottomSafeArea = bottomSafeArea

        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        self._viewModel = StateObject(
            wrappedValue: MyRecordBottomSheetViewModel(
                fetchMyRecordsUseCase: fetchMyRecordsUseCase
            )
        )
    }


    var body: some View {
        let isLarge = (sheetDetent == .large)
        let currentOffset: CGFloat =
            isLarge ? detentOffsets.large : detentOffsets.low

        ZStack(alignment: .top) {

            VStack(spacing: 12) {
                if sheetDetent == .low {
                    VStack(alignment: .leading) {
                        Text("내 꽃")
                            .font(DesignSystem.Font.Title1.semibold)
                            .foregroundColor(DesignSystem.Color.Gray_black)
                            .padding(.bottom, 8)

                        if totalCount == 0 {
                            Text("기록한 꽃이 없습니다")
                                .font(DesignSystem.Font.Title3.semibold)
                                .foregroundColor(DesignSystem.Color.Gray_03)
                        } else {
                            Text("\(totalCount)개의 꽃")
                                .font(DesignSystem.Font.Title3.semibold)
                                .foregroundColor(DesignSystem.Color.Gray_03)
                        }

                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .transition(.opacity)
                    .background(.white)
                    .opacity(sheetDetent == .low ? 1 : 0)

                }

                if sheetDetent == .large {
                    ScrollViewReader { _ in
                        BouncingControlledScrollView(isScrollEnabled: true) {
                            VStack(spacing: 20) {
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetKey.self,
                                            value: geo.frame(
                                                in: .named("scroll")
                                            ).minY
                                        )
                                }
                                .frame(height: 0)

                                Text("내 꽃")
                                    .font(
                                        DesignSystem.Font.NavigationTitle.bold
                                    )
                                    .foregroundColor(
                                        DesignSystem.Color.Gray_black
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .topLeading
                                    )

                                // 전체 기록 버튼
                                AllRecordButtonView(
                                    totalCount: viewModel.allMotes.count,
                                    onTap: {
                                        print("전체 기록 보기로 이동")
                                        nav.push(.myRecord)
                                    }
                                )

                                FilteredMoteListView(
                                    filteredMotes: viewModel.filteredMotes,
                                    currentAddress: locationManager
                                        .currentAddress,
                                    onRecordTap: { id in
                                        selectedRecordID = IdentifiableUUID(
                                            id: id
                                        )

                                    }
                                )
                                .padding(.bottom, 16)

                                VStack(spacing: 8) {
                                    Text("지도")
                                        .font(DesignSystem.Font.Title2.bold)
                                        .foregroundColor(
                                            DesignSystem.Color.Gray_black
                                        )
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )

                                    if let location = locationManager
                                        .currentLocation
                                    {
                                        CurrentLocationMapView(
                                            location: location.coordinate
                                        ) {
                                            print("지도 눌림 – 맵뷰로 이동")
                                            nav.push(.map)
                                        }
                                    }
                                }

                                Spacer(minLength: 90)

                            }
                            .background(DesignSystem.Color.BgScreen)
                        }
                        .padding(.top, 130)
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollOffsetKey.self) { offset in
                            isAtTop = offset >= 0
                            print("[Debug] Scroll offset:", offset)
                            print("[Debug] isAtTop 상태:", isAtTop)
                        }
                    }
                    .transition(.opacity)
                    .opacity(sheetDetent == .large ? 1 : 0)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: sheetDetent)

            VStack(spacing: 5) {
                grabberArea
                    .padding(.top, 10)

                if isLarge {
                    HeaderBarView {
                        // 설정 버튼 등 작업
                    } onCloseTapped: {
                        withAnimation {
                            sheetDetent = .low
                        }
                    }
                }
            }
            .background(Color.clear)
        }
        .padding(.horizontal, 20)
        .background(.white)
        .cornerRadius(
            (isLarge && !isDragging) ? 0 : 20,
            corners: [.topLeft, .topRight]
        )
        .cornerRadius(
            (!isDraggingDown) ? 0 : 20,
            corners: [.topLeft, .topRight]
        )
        .shadow(color: .black.opacity(0.05), radius: 50, x: 0, y: 0)
        .offset(
            y: {
                let rawOffset = currentOffset + dragTranslation
                let screenHeight = UIScreen.main.bounds.height
                return min(rawOffset, screenHeight - bottomSafeArea)
            }()
        )
        .gesture(
            DragGesture(minimumDistance: 2)
                .onChanged { value in
                    let dy = value.translation.height

                    switch sheetDetent {
                    case .large where isAtTop && dy > 0:
                        // 시트 내림
                        dragTranslation = dy
                        isDraggingDown = true
                        isDraggingUp = false

                    case .low where dy < 0:
                        // 시트 올림
                        dragTranslation = dy
                        isDraggingUp = true
                        isDraggingDown = false

                    default:
                        // 다른 상황: 드래그 무시
                        dragTranslation = 0
                        isDraggingDown = false
                        isDraggingUp = false
                    }
                }
                .onEnded { value in
                    let dy = value.translation.height

                    switch sheetDetent {
                    case .low where dy < -50:
                        withAnimation {
                            sheetDetent = .large
                        }

                    case .large where isAtTop && dy > 50:
                        withAnimation {
                            sheetDetent = .low
                        }

                    default:
                        // 조건 불충족: 시트 고정
                        break
                    }

                    dragTranslation = 0
                    isDraggingUp = false
                    isDraggingDown = false
                }
        )

        .onReceive(locationManager.$currentLocation.compactMap { $0 }) {
            location in
            viewModel.loadAllMotes()
            locationManager.requestLocationAgain()
            viewModel.filterMotesByLocation(currentLocation: location)
        }
        .onAppear {
            viewModel.loadAllMotes()
            locationManager.requestLocationAgain()
        }
        .ignoresSafeArea(.all)
        .sheet(item: $selectedRecordID) { identifiableID in
            // @Dependency로 UseCase를 가져옵니다.
            @Dependency(\.fetchRecordDetailUseCase) var fetchRecordDetailUseCase
            
            RecordDetailBottomSheet(
                // 생성자에 id와 함께 useCase를 전달합니다.
                viewModel: RecordDetailViewModel(
                    id: identifiableID.id,
                    fetchRecordDetailUseCase: fetchRecordDetailUseCase
                )

            )
        }

    }

    private var grabberArea: some View {
        let shouldShowGrabber = sheetDetent == .large && !isAtTop

        let paddingTop: CGFloat
        if isDraggingUp {
            paddingTop = 0  // low->large 올리는 중, 약간 낮게
        } else if isDraggingDown {
            paddingTop = 0  // large->low 내리는 중, 좀 더 올려서 자연스럽게
        } else {
            paddingTop = (sheetDetent == .large) ? 60 : 0
        }

        return Capsule()
            .fill(Color.secondary)
            .frame(width: 40, height: 5)
            .padding(.top, paddingTop)
            .opacity(shouldShowGrabber ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: paddingTop)
            .animation(.easeInOut(duration: 0.3), value: shouldShowGrabber)
    }

}

// MARK: - ScrollOffsetKey

struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - BouncingControlledScrollView

struct BouncingControlledScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    var isScrollEnabled: Bool

    init(
        isScrollEnabled: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isScrollEnabled = isScrollEnabled
    }

    // 👇 1. Coordinator 생성
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // 👈 2. delegate 지정
        scrollView.alwaysBounceVertical = true  // 아래쪽 바운스 유지
        scrollView.bounces = isScrollEnabled
        scrollView.isScrollEnabled = isScrollEnabled

        let host = UIHostingController(rootView: content)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            host.view.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor
            ),
            host.view.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor
            ),
            host.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.isScrollEnabled = isScrollEnabled
        scrollView.bounces = isScrollEnabled  // 필요하면 true 유지

        if let host = scrollView.subviews
            .compactMap({ $0.next as? UIHostingController<Content> })
            .first
        {
            host.rootView = content
        }
    }

    // 👇 3. 최상단에서 음수 offset 무효화
    class Coordinator: NSObject, UIScrollViewDelegate {
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.y < 0 {
                scrollView.contentOffset.y = 0  // 위로 끌면 즉시 0으로
            }
        }
    }
}

struct LocationMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    MainView()
}
