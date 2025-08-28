import ARKit
import CoreLocation
import Dependencies
import DesignSystem
import Domain
import RealityKit
import SwiftUI

@available(iOS 18.0, *)
public struct ARCameraView: View {
    @StateObject private var viewModel: ARCameraViewModel
    @StateObject private var permissionsManager = PermissionsManager()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showPermissionAlert = false
    @StateObject private var bottomSheetCoordinator: BottomSheetCoordinator

    public init(location: CLLocation) {
        @Dependency(\.fetchMyRecordsUseCase) var fetchMyRecordsUseCase
        @Dependency(\.saveRecordUseCase) var saveRecordUseCase
        @Dependency(\.fetchAllMarkersUseCase) var fetchAllMarkersUseCase
        @Dependency(\.fetchRecordDetailUseCase) var fetchRecordDetailUseCase

        let coordinator = BottomSheetCoordinator(
            fetchAllMarkersUseCase: fetchAllMarkersUseCase,
            fetchRecordDetailUseCase: fetchRecordDetailUseCase
        )
        
        let viewModel = ARCameraViewModel(
            fetchMyRecordsUseCase: fetchMyRecordsUseCase,
            saveRecordUseCase: saveRecordUseCase,
            fetchAllMarkersUseCase: fetchAllMarkersUseCase,
            location: location,
            bottomSheetCoordinator: coordinator
        )
        
        _viewModel = StateObject(wrappedValue: viewModel)
        _bottomSheetCoordinator = StateObject(wrappedValue: coordinator)
    }
    
    public var body: some View {
        ZStack {
            if permissionsManager.status == .granted {
                ARContentView(viewModel: viewModel,  dismiss: dismiss)
                    .onAppear {
                        print("ARCameraView onAppear - AR 세션 시작")
                        viewModel.startARSession()
                    }
                    .onDisappear {
                        print("ARCameraView onDisappear - AR 세션 중지")
                        viewModel.pauseARSession()
                    }
            } else {
                ARPermissionPlaceholderView()
            }
        }
        .onAppear {
            checkAndRequestPermissions()
        }
        .onChange(of: scenePhase) { phase in
            handleScenePhaseChange(phase)
        }
        .alert("카메라 접근 권한 필요", isPresented: $showPermissionAlert) {
            Button("설정") {
                openSettings()
            }
            Button("취소", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("AR 경험을 위해 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.")
        }
        .bottomSheetCoordinator(coordinator: viewModel.bottomSheetCoordinator)
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            print("앱이 활성 상태로 전환 - AR 세션 재개")
            if permissionsManager.status == .granted {
                viewModel.resumeARSession()
            }
        case .inactive, .background:
            print("앱이 비활성/백그라운드 상태로 전환 - AR 세션 일시정지")
            viewModel.pauseARSession()
        @unknown default:
            break
        }
    }
    
    private func checkAndRequestPermissions() {
        permissionsManager.check()
        
        switch permissionsManager.status {
        case .unknown:
            Task {
                await permissionsManager.request()
                if permissionsManager.status == .denied {
                    showPermissionAlert = true
                }
            }
        case .denied:
            showPermissionAlert = true
        case .granted:
            break
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - ARPermissionPlaceholderView

@available(iOS 18.0, *)
private struct ARPermissionPlaceholderView: View {
    var body: some View {
        Color.black
            .ignoresSafeArea()
            .overlay(
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.5))
                    Text("카메라 준비 중...")
                        .foregroundColor(.white.opacity(0.7))
                }
            )
    }
}

// MARK: - ARContentView

@available(iOS 18.0, *)
private struct ARContentView: View {
    @ObservedObject var viewModel: ARCameraViewModel
    @EnvironmentObject private var nav: NavigationViewModel

    let dismiss: DismissAction
    
    var body: some View {
        ZStack {
            ARViewContainer(sceneManager: viewModel.arSceneManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ARTopBarView(
                    onClose: {
                        print("AR 화면 종료")
                        viewModel.pauseARSession()
                        dismiss()
                    },
                    onCancelPlacement: viewModel.cancelPlacement,
                    onMapTapped: {
                        print("🗺️ Map button tapped")
                        print("📍 Current navigation path: \(nav.path)")
                        viewModel.pauseARSession()
                        
                        // 바로 push 하지 말고, AR에서 나간 후 맵으로 이동
                        nav.pop() // AR에서 나가기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            nav.push(.map) // 맵으로 이동
                            print("📍 Updated navigation path: \(nav.path)")
                        }
                    },
                    mode: viewModel.cameraMode
                )
                
                ARDebugInfoView(viewModel: viewModel)
                
                Spacer()
                
                ARStatusView(message: viewModel.statusMessage)
                ARBottomBarView(
                    mode: viewModel.cameraMode,
                    isPlacementConfirmed: viewModel.isPlacementConfirmed,
                    onSwitchToPlacement: viewModel.switchToPlacementMode,
                    onSelectFlower: viewModel.showFlowerSelectionSheet,
                    onCancelPlacement: viewModel.cancelPlacement,
                    onConfirmPlacement: viewModel.confirmPlacement,
                    onRepositionPlacement: viewModel.repositionPlacement,
                    onSave: viewModel.requestSave,
                    status: viewModel.raycastStatus
                )
            }
            .padding()
        }
    }
}

// MARK: - ARDebugInfoView

@available(iOS 18.0, *)
private struct ARDebugInfoView: View {
    @ObservedObject var viewModel: ARCameraViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HeadingDebugView(
                heading: viewModel.currentHeading,
                direction: viewModel.currentDirection
            )
            
            CameraPitchView(
                pitch: viewModel.currentPitch,
                direction: viewModel.currentPitchDirection
            )
            
            RaycastStatusView(
                status: viewModel.raycastStatus,
                distance: viewModel.raycastDistance
            )
        }
    }
}

// MARK: - ARViewContainer

@available(iOS 18.0, *)
internal struct ARViewContainer: UIViewRepresentable {
    public let sceneManager: ARSceneManager
    
    public func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        sceneManager.setup(arView: arView)
        return arView
    }
    
    public func updateUIView(_ uiView: ARView, context: Context) {
        // ARView 업데이트가 필요한 경우 여기에 로직 추가
    }
}

// MARK: - HeadingDebugView

@available(iOS 18.0, *)
internal struct HeadingDebugView: View {
    let heading: Double
    let direction: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.north.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
                .rotationEffect(.degrees(-heading))
                .animation(.easeInOut(duration: 0.2), value: heading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(String(format: "%.1f", heading))°")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(direction)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
        .padding(.horizontal)
    }
}

// MARK: - CameraPitchView

@available(iOS 18.0, *)
internal struct CameraPitchView: View {
    let pitch: Double
    let direction: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: getCameraIcon())
                .font(.title2)
                .foregroundColor(getIconColor())
                .rotationEffect(.degrees(pitch))
                .animation(.easeInOut(duration: 0.2), value: pitch)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(String(format: "%.1f", pitch))°")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(direction)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
        .padding(.horizontal)
    }
    
    private func getCameraIcon() -> String {
        switch pitch {
        case 30...: return "camera.rotate"
        case 10..<30: return "camera"
        case -10..<10: return "camera.fill"
        case -30..<(-10): return "camera"
        case ..<(-30): return "camera.rotate"
        default: return "camera.fill"
        }
    }
    
    private func getIconColor() -> Color {
        switch pitch {
        case 60...: return .cyan
        case 30..<60: return .blue
        case 10..<30: return .green
        case -10..<10: return .white
        case -30..<(-10): return .yellow
        case -60..<(-30): return .orange
        case ..<(-60): return .red
        default: return .white
        }
    }
}

// MARK: - RaycastStatusView

@available(iOS 18.0, *)
internal struct RaycastStatusView: View {
    let status: ARSceneManager.RaycastStatus
    let distance: Float
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: getStatusIcon())
                .font(.title2)
                .foregroundColor(Color(status.color))
                .animation(.easeInOut(duration: 0.3), value: status.displayText)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("RayCast")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(status.displayText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
        .padding(.horizontal)
    }
    
    private func getStatusIcon() -> String {
        switch status {
        case .idle:
            return "eye.slash"
        case .success:
            return "eye.fill"
        case .fallback:
            return "eye.trianglebadge.exclamationmark"
        case .failed:
            return "eye.slash.fill"
        }
    }
}
