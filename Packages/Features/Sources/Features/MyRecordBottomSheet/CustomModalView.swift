//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/24/25.
//

import SwiftUI
import MapKit
import CoreLocation

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
    
    @StateObject private var viewModel = MyRecordBottomSheetViewModel()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var nav: NavigationViewModel
    
    let detentOffsets: (large: CGFloat, low: CGFloat)
    let bottomSafeArea: CGFloat
    
    @State private var dragTranslation: CGFloat = 0
    
    @State private var isAtTop: Bool = true
    @GestureState private var isDraggingGesture: Bool = false
    var isDragging: Bool { isDraggingGesture }
    @State private var isDraggingUp = false      // .low -> .large 전환 중
    @State private var isDraggingDown = false    // .large -> .low 전환 중
    
    var body: some View {
        let isLarge = (sheetDetent == .large)
        let currentOffset: CGFloat = isLarge ? detentOffsets.large : detentOffsets.low
        
        ZStack(alignment: .top) {
            
            
            VStack(spacing:12) {
                if sheetDetent == .low {
                    VStack(alignment: .leading) {
                        Text("내 꽃")
                            .font(
                                Font.custom("Pretendard", size: 24)
                                    .weight(.semibold)
                            )
                            .padding(.bottom, 8)
                        
                        Text("\(totalCount)개의 꽃")
                            .font(
                                Font.custom("Pretendard", size: 16)
                                    .weight(.semibold)
                            )
                            .foregroundColor(Color(red: 0.41, green: 0.49, blue: 0.6).opacity(0.72))
                        
                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .transition(.opacity)
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
                                            value: geo.frame(in: .named("scroll")).minY
                                        )
                                }
                                .frame(height: 0)
                                
                                Text("내 꽃")
                                    .font(
                                        Font.custom("Pretendard", size: 26)
                                            .weight(.bold)
                                    )
                                    .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.14))
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                
                                
                                
                                // 전체 기록 버튼
                                AllRecordButtonView(
                                    totalCount: viewModel.allMotes.count,
                                    onTap: {
                                        print("전체 기록 보기로 이동")
                                    }
                                )
                                
                                FilteredMoteListView(
                                    filteredMotes: viewModel.filteredMotes,
                                    currentAddress: locationManager.currentAddress
                                )
                                
                                VStack{}.frame(height: 20)
                                
                                //                                지도
                                Text("지도")
                                    .font(
                                        Font.custom("Pretendard", size: 18)
                                            .weight(.bold)
                                    )
                                    .foregroundColor(Color(red: 0.1, green: 0.12, blue: 0.15))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let location = locationManager.currentLocation {
                                    CurrentLocationMapView(location: location.coordinate) {
                                        print("지도 눌림 – 맵뷰로 이동")
                                    }
                                }
                                
                                Spacer(minLength: 80)
                               
                                
                                
                            }
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
        .padding(.horizontal,20)
        .background(.white)
        .cornerRadius((isLarge && !isDragging) ? 0 : 20, corners: [.topLeft, .topRight])
        .cornerRadius((!isDraggingDown) ? 0 : 20, corners: [.topLeft, .topRight])
        .shadow(radius: isLarge ? 0 : 10)
        .offset(y: {
            let rawOffset = currentOffset + dragTranslation
            let screenHeight = UIScreen.main.bounds.height
            return min(rawOffset, screenHeight - bottomSafeArea)
        }())
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
        
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
            viewModel.filterMotesByLocation(currentLocation: location)
            
        }
        .onAppear {
            viewModel.loadAllMotes()
            if let current = locationManager.currentLocation {
                viewModel.filterMotesByLocation(currentLocation: current)
            }
        }
        
        
        .ignoresSafeArea(.all)
    }
    
    private var grabberArea: some View {
        let shouldShowGrabber = sheetDetent == .large && !isAtTop
        
        let paddingTop: CGFloat
        if isDraggingUp {
            paddingTop = 0   // low->large 올리는 중, 약간 낮게
        } else if isDraggingDown {
            paddingTop = 0   // large->low 내리는 중, 좀 더 올려서 자연스럽게
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
    
    init(isScrollEnabled: Bool = true,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isScrollEnabled = isScrollEnabled
    }
    
    // 👇 1. Coordinator 생성
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator        // 👈 2. delegate 지정
        scrollView.alwaysBounceVertical = true           // 아래쪽 바운스 유지
        scrollView.bounces = isScrollEnabled
        scrollView.isScrollEnabled = isScrollEnabled
        
        let host = UIHostingController(rootView: content)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            host.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.isScrollEnabled = isScrollEnabled
        scrollView.bounces = isScrollEnabled               // 필요하면 true 유지
        
        if let host = scrollView.subviews
            .compactMap({ $0.next as? UIHostingController<Content> })
            .first {
            host.rootView = content
        }
    }
    
    // 👇 3. 최상단에서 음수 offset 무효화
    class Coordinator: NSObject, UIScrollViewDelegate {
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.y < 0 {
                scrollView.contentOffset.y = 0            // 위로 끌면 즉시 0으로
            }
        }
    }
}

struct LocationMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
