//
//  ToolbarHiddenWrapper.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//


import SwiftUI

struct ToolbarHiddenWrapper<Content: View>: View {
    var content: Content
    var body: some View {
        content
            .toolbar(.hidden, for: .navigationBar)
    }
}