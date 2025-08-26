//
//  NavigationViewModel.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import SwiftUI

public final class NavigationViewModel: ObservableObject {
    @Published public var path: [AppRoute] = []

    public init() {}

    public func push(_ route: AppRoute) {
        path.append(route)
    }
    
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func reset() { path.removeAll() }

    public func goHome() {
        path.removeAll()
        path.append(AppRoute.home)
    }
}
