//
//  SwiftUIView.swift
//  Features
//
//  Created by Woody on 7/21/25.
//

import SwiftUI
import DesignSystem

struct ARButton: View {
    let action: () -> Void
    
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        Button(action: action) {
                DesignSystemAssets.image(named: "homeflower")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 364, height: 364)
            }
            .buttonStyle(PlainButtonStyle())
        }

    }




