import Dependencies
import Features  // Only import Features
import SwiftData
import SwiftUI

@main
struct MoteApp: App {
    init() {
        AppDI.registerDependencies()  // Register all dependencies at app launch
    }

    var body: some Scene {
        WindowGroup {
            NavigationHostView()
                .environmentObject(NavigationViewModel())
        }
    }
}
