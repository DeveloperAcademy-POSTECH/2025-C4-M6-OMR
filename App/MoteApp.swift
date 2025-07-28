import Dependencies
import Features  // Only import Features
import SwiftData
import SwiftUI

@main
struct MoteApp: App {
    init() {
        // Setup global dependencies at app launch
        AppDI.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationHostView()
                .environmentObject(NavigationViewModel())
        }
    }
}
