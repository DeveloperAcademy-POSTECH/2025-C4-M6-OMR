import ARKit
import CoreLocation
import RealityKit
import SwiftUI
import DesignSystem

public struct ARCameraView: View {
    @StateObject private var viewModel: ARCameraViewModel
    @StateObject private var permissionsManager = PermissionsManager()
    @Environment(\.dismiss) private var dismiss

    @State private var showPermissionAlert = false

    public init(location: CLLocation) {
        // 1) Coordinator 생성
        let coordinator = BottomSheetCoordinator()
        // 2) ViewModel 생성 시 DI
        let viewModel = ARCameraViewModel(
            location: location,
            bottomSheetCoordinator: coordinator
        )
        // 3) StateObject에 래핑
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
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                ARTopBarView(onClose: { dismiss() })
                Spacer()
                ARStatusView(message: viewModel.statusMessage)
                ARBottomBarView(
                    mode: viewModel.cameraMode,
                    isPlacementConfirmed: viewModel.isPlacementConfirmed,
                    onSwitchToPlacement: viewModel.switchToPlacementMode,
                    onCancelPlacement: viewModel.cancelPlacement,
                    onConfirmPlacement: viewModel.confirmPlacement,
                    onRepositionPlacement: viewModel.repositionPlacement,
                    onSave: viewModel.requestSave
                )
            }
            .padding()
        }
    }
}

// MARK: - ARViewContainer
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARCameraViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.setupARView(arView)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // ARView 업데이트가 필요한 경우 여기에 로직 추가
    }
}
