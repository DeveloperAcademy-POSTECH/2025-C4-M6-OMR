//
//  DesignSystemAssets.swift
//  DesignSystem
//
//  Created by eunsong on 7/21/25.
//
import SwiftUI

public enum DesignSystemAssets {
    public static func image(named name: String) -> Image {
        let bundle = Bundle.module
        return Image(name, bundle: bundle)
    }

    public static func uiImage(named name: String) -> UIImage? {
        let bundle = Bundle.module
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
