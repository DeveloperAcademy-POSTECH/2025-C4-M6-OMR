//
//  ARPlacementState.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import Foundation
import SwiftUI
import RealityKit
import ARKit

@MainActor
class ARPlacementState: ObservableObject {
    enum Status {
        case idle
        case placing
        case confirmed
    }
    
    @Published private(set) var status: Status = .idle
    
    private(set) var entity: ModelEntity?
    private(set) var flower: ARFlower?
    private var temporaryAnchor: AnchorEntity?
    private var confirmedAnchor: AnchorEntity?
    
    var canConfirm: Bool {
        status == .placing && entity != nil
    }
    
    func setEntity(_ entity: ModelEntity, flower: ARFlower) {
        self.entity = entity
        self.flower = flower
        self.status = .placing
    }
    
    // updatePosition 함수 제거됨 - preview flower 표시 기능 제거
    
    func confirm() {
        guard canConfirm else { return }
        status = .confirmed
    }
    
    func createPermanentAnchor() -> AnchorEntity? {
        guard let entity = entity,
              let temporaryAnchor = temporaryAnchor else { return nil }
        
        let permanentAnchor = AnchorEntity(world: temporaryAnchor.transform.matrix)
        permanentAnchor.addChild(entity.clone(recursive: true))
        
        // 임시 앵커 제거
        temporaryAnchor.scene?.removeAnchor(temporaryAnchor)
        self.temporaryAnchor = nil
        self.confirmedAnchor = permanentAnchor
        
        return permanentAnchor
    }
    
    func startRepositioning(in arView: ARView) {
        guard status == .confirmed else { return }
        
        if let anchor = confirmedAnchor {
            arView.scene.removeAnchor(anchor)
            self.confirmedAnchor = nil
        }
        
        status = .placing
    }
    
    func removeFrom(arView: ARView) {
        if let anchor = temporaryAnchor {
            arView.scene.removeAnchor(anchor)
            self.temporaryAnchor = nil
        }
        
        if let anchor = confirmedAnchor {
            arView.scene.removeAnchor(anchor)
            self.confirmedAnchor = nil
        }
        
        reset()
    }
    
    func reset() {
        entity = nil
        flower = nil
        status = .idle
    }
}
