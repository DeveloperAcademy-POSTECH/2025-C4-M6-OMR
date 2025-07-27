import Dependencies
import Domain
import SwiftUI

// MARK: - Alternative Approach using Environment
// This approach passes dependencies through SwiftUI Environment
// and applies them in navigationDestination

public struct NavigationDependencies {
    public let recordRepository: RecordRepository
    public let userRepository: UserRepository
    public let markerRepository: MarkerRepository
    
    public init(
        recordRepository: RecordRepository,
        userRepository: UserRepository,
        markerRepository: MarkerRepository
    ) {
        self.recordRepository = recordRepository
        self.userRepository = userRepository
        self.markerRepository = markerRepository
    }
}

private struct NavigationDependenciesKey: EnvironmentKey {
    static let defaultValue: NavigationDependencies? = nil
}

extension EnvironmentValues {
    public var navigationDependencies: NavigationDependencies? {
        get { self[NavigationDependenciesKey.self] }
        set { self[NavigationDependenciesKey.self] = newValue }
    }
}

extension View {
    public func navigationDependencies(_ deps: NavigationDependencies) -> some View {
        self.environment(\.navigationDependencies, deps)
    }
}

// MARK: - Updated NavigationHostView using Environment
public struct NavigationHostViewAlt: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @Environment(\.navigationDependencies) private var navDeps

    public init() {}

    public var body: some View {
        NavigationStack(path: $nav.path) {
            MainView()
                .navigationDestination(for: AppRoute.self) { route in
                    if let deps = navDeps {
                        // Wrap with dependencies from environment
                        withDependencies {
                            $0.recordRepository = deps.recordRepository
                            $0.userRepository = deps.userRepository
                            $0.markerRepository = deps.markerRepository
                        } operation: {
                            destinationView(for: route)
                        }
                    } else {
                        Text("Dependencies not configured")
                    }
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        // Same implementation as before
    }
}

// Usage in App:
// NavigationHostView()
//     .navigationDependencies(NavigationDependencies(
//         recordRepository: AppDI.recordRepository,
//         userRepository: AppDI.userRepository,
//         markerRepository: AppDI.markerRepository
//     ))
//     .environmentObject(NavigationViewModel())