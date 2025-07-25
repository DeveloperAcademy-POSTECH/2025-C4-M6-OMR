import ARKit
import RealityKit
import SwiftUI
import CoreLocation

public struct ARCameraView: View {
    @StateObject private var viewModel: ARCameraViewModel
    @StateObject private var permissionsManager = PermissionsManager()
    @Environment(\.dismiss) private var dismiss

    public init(location: CLLocation) {
        print(">>> ARCameraView init\n \(location)")
        _viewModel = StateObject(wrappedValue: ARCameraViewModel(location: location))
    }

    public var body: some View {
        Group {
            switch permissionsManager.status {
            case .unknown:
                PermissionRequestView(manager: permissionsManager)
            case .denied:
                PermissionDeniedView()
            case .granted:
                arContentView
                    .onAppear(perform: viewModel.startARSession)
            }
        }
        .onAppear {
            permissionsManager.check()
        }
    }

    private var arContentView: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                topBarView
                Spacer()
                statusMessageView
                bottomBarView
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.viewData.isShowingRecordDetailSheet) {
            if let record = viewModel.viewData.selectedRecord {
                // TODO: 실제 Record 객체를 전달하도록 수정 필요
//                 RecordDetailBottomSheet(viewModel: .init(summary: summary))
            }
        }
        .sheet(isPresented: $viewModel.viewData.isShowingFlowerSelectionSheet) {
            FlowerSelectionBottomSheet(viewModel: viewModel.flowerSelectionViewModel)
        }
        .sheet(isPresented: $viewModel.viewData.isShowingSaveSheet) {
            if let flower = viewModel.viewData.selectedFlower {
                // TODO: 실제 Flower 객체를 전달하도록 수정 필요
//                 RecordSaveSheetView(viewModel: .init(flower: flower))
            }
        }
    }

    private var topBarView: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }

    private var statusMessageView: some View {
        Text(viewModel.viewData.statusMessage)
            .padding(12)
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 20)
            .animation(.easeInOut, value: viewModel.viewData.statusMessage)
    }

    @ViewBuilder
    private var bottomBarView: some View {
        switch viewModel.viewData.cameraMode {
        case .normal:
            Button(action: viewModel.switchToPlacementMode) {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .padding(20)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
        case .placement:
            HStack(spacing: 30) {
                Button(action: viewModel.cancelPlacement) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }

                Button(action: {
                    if viewModel.viewData.isPlacementConfirmed {
                        viewModel.repositionPlacement()
                    } else {
                        viewModel.confirmPlacement()
                    }
                }) {
                    Image(
                        systemName: viewModel.viewData.isPlacementConfirmed
                            ? "arrow.uturn.backward" : "checkmark"
                    )
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .padding(20)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                }

                if viewModel.viewData.isPlacementConfirmed {
                    Button(action: {
                        viewModel.viewData.isShowingSaveSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(Circle())
                    }
                } else {
                    // A transparent circle to maintain layout
                    Circle().fill(Color.clear).frame(width: 60, height: 60)
                }
            }
        }
    }
}

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

    func updateUIView(_ uiView: ARView, context: Context) {}
}
