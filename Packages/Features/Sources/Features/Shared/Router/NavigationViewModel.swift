//
//  NavigationViewModel.swift
//  Features
//
//  Created by eunsong on 7/15/25.
//
import SwiftUI

public final class NavigationViewModel: ObservableObject {
    @Published public var path = NavigationPath()

    public init() {}

    public func push(_ route: AppRoute) {
        path.append(route)
    }

    public func reset() { path = .init() }

    public func goHome() {
        path = .init()
        path.append(AppRoute.home)
    }
}
