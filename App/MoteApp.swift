import Dependencies
import DesignSystem
import Features  // Only import Features
import SwiftData
import SwiftUI

@main
struct MoteApp: App {
    
    init() {
        // Setup global dependencies at app launch
        AppDI.setup()
        
        // Register DesignSystem fonts
        DesignSystem.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationHostView()
                .environmentObject(NavigationViewModel())
        }
    }
}
