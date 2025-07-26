import Dependencies
import Features  // Only import Features
import SwiftData
import SwiftUI

@main
struct MoteApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationHostView()
                .environmentObject(NavigationViewModel())
                .injectAppDependencies()
        }
    }
}
