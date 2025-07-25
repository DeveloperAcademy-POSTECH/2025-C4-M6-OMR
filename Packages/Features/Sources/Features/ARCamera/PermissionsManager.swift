//
//  PermissionsManager.swift
//
//
//  Created by eunsong on 2024/07/24.
//

import Foundation
import AVFoundation

@MainActor
class PermissionsManager: ObservableObject {
    enum Status {
        case unknown
        case granted
        case denied
    }

    @Published var status: Status = .unknown

    init() {
        check()
    }

    func check() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            status = .granted
        case .notDetermined:
            status = .unknown
        case .denied, .restricted:
            status = .denied
        @unknown default:
            status = .unknown
        }
    }

    func request() async {
        // Run the blocking call on a background thread to avoid deadlocking the MainActor.
        let granted = await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        
        if granted {
            status = .granted
        } else {
            status = .denied
        }
    }
}