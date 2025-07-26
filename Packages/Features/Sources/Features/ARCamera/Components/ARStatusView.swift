//
//  ARStatusView.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import SwiftUI

struct ARStatusView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding(12)
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 20)
            .animation(.easeInOut, value: message)
    }
}
