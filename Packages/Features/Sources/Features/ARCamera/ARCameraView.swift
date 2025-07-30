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
    
    @State private var showPermissionAlert = false
    
    public init(
        location: CLLocation,
        factory: ARCameraViewModelFactory
    ) {
        @Dependency(\.bottomSheetCoordinatorFactory) var coordinatorFactory
        let coordinator = coordinatorFactory.create()
        //        let coordinator = BottomSheetCoordinator()
        let viewModel = factory.create(
            location: location,
            bottomSheetCoordinator: coordinator
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            if permissionsManager.status == .granted {
                arContentView
                    .onAppear { viewModel.startARSession() }
            } else {
                // 권한이 없을 때 보여줄 플레이스홀더
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
        .onAppear {
            checkAndRequestPermissions()
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
    
    private var arContentView: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                ARViewContainer(sceneManager: viewModel.arSceneManager)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Fallback on earlier versions
            }
            
            VStack {
                ARTopBarView(
                    onClose: { dismiss() },
                    onCancelPlacement: viewModel.cancelPlacement,
                    mode: viewModel.cameraMode
                )
                
                // 실시간 헤딩 정보 표시
                HeadingDebugView(
                    heading: viewModel.currentHeading,
                    direction: viewModel.currentDirection
                )
                
                CameraPitchView(
                    pitch: viewModel.currentPitch,
                    direction: viewModel.currentPitchDirection
                )
                
                // RayCast 상태 표시
                RaycastStatusView(
                    status: viewModel.raycastStatus,
                    distance: viewModel.raycastDistance
                )
                
                
               
              
                
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
            // 나침반 아이콘
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

@available(iOS 18.0, *)
internal struct CameraPitchView: View {
    let pitch: Double
    let direction: String
    
    var body: some View {
        HStack(spacing: 12) {
            // 카메라 방향 아이콘
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
        case 60...: return .cyan    // 하늘
        case 30..<60: return .blue  // 위쪽
        case 10..<30: return .green // 약간 위
        case -10..<10: return .white // 수평
        case -30..<(-10): return .yellow // 약간 아래
        case -60..<(-30): return .orange // 아래쪽
        case ..<(-60): return .red   // 바닥
        default: return .white
        }
    }
}

// MARK: - RaycastStatusView (새로 추가)
@available(iOS 18.0, *)
internal struct RaycastStatusView: View {
    let status: ARSceneManager.RaycastStatus
    let distance: Float
    
    var body: some View {
        HStack(spacing: 12) {
            // RayCast 상태 아이콘
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
