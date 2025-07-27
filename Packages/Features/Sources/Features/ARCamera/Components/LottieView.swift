//
//  LottieView.swift
//  Features
//
//  Created by eunsong on 7/27/25.
//

import Lottie
import SwiftUI

public struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let isPlaying: Bool
    var bundle: Bundle

    public init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        isPlaying: Bool = true,
        bundle: Bundle = .main
    ) {
        self.name = name
        self.loopMode = loopMode
        self.isPlaying = isPlaying
        self.bundle = bundle
    }

    public func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name, bundle: bundle)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false 
        if isPlaying {
            animationView.play()
        }
        return animationView
    }

    public func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if isPlaying {
            uiView.play()
        } else {
            uiView.stop()
        }
    }
}

#Preview{
    LottieView(
        name: "indicator_diamond",
        isPlaying: true,
        bundle: .module
    )
    .frame(width: 50, height: 50)
}
