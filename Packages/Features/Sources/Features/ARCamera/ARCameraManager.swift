import ARKit
import Combine
import RealityKit
import SwiftUI

@MainActor
protocol ARCameraManagerDelegate: AnyObject {
    func cameraManagerDidUpdateFocusState(isFocused: Bool)
}

@MainActor
class ARCameraManager {
    weak var arView: ARView?
    weak var delegate: ARCameraManagerDelegate?

    private var isCameraFocused = false
    private var currentFocusedMarker: ARMarker?

    // 시각적 피드백을 위한 오버레이
    private var focusOverlay: ModelEntity?

    init(arView: ARView) {
        self.arView = arView
        setupFocusOverlay()
    }

    private func setupFocusOverlay() {
        // AR 카메라 자체를 이동시킬 수 없으므로,
        // 대신 화면 중앙에 포커스 인디케이터를 표시
        print("📷 Setting up camera focus system")
    }

    // MARK: - Focus Management

    func focus(on marker: ARMarker) {
        guard !isCameraFocused || currentFocusedMarker !== marker else {
            return
        }

        // Store the currently focused marker
        currentFocusedMarker = marker

        print("📷 Camera focusing on marker: \(marker.record.id)")

        // 시각적 피드백 제공
        provideVisualFeedback(for: marker)

        self.isCameraFocused = true
        self.delegate?.cameraManagerDidUpdateFocusState(isFocused: true)
    }

    func resetFocus() {
        guard isCameraFocused else { return }

        // Clear the focused marker
        currentFocusedMarker = nil

        print("📷 Camera focus reset")

        // 시각적 피드백 제거
        removeVisualFeedback()

        self.isCameraFocused = false
        self.delegate?.cameraManagerDidUpdateFocusState(isFocused: false)
    }

    // MARK: - Visual Feedback

    private func provideVisualFeedback(for marker: ARMarker) {
        guard let arView = arView else { return }

        // 화면에 subtle한 비네팅 효과나 하이라이트를 추가할 수 있음
        // 하지만 RealityKit에서는 직접적인 포스트 프로세싱이 제한적이므로
        // 마커 자체의 시각적 효과에 의존

        print(
            "📷 Visual feedback activated for marker at position: \(marker.position(relativeTo: nil))"
        )
    }

    private func removeVisualFeedback() {
        print("📷 Visual feedback removed")
    }

    // MARK: - Public Properties

    var isFocused: Bool {
        return isCameraFocused
    }

    var focusedMarker: ARMarker? {
        return currentFocusedMarker
    }
}

// MARK: - Extensions for Camera Transform Access
extension ARView {
    var cameraTransform: Transform {
        guard let frame = session.currentFrame else {
            return Transform()
        }

        let translation = SIMD3<Float>(
            frame.camera.transform.columns.3.x,
            frame.camera.transform.columns.3.y,
            frame.camera.transform.columns.3.z
        )

        return Transform(translation: translation)
    }
}
