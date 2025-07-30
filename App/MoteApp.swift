import Dependencies
import DesignSystem
import Domain
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
            // NavigationHostView를 생성하며 후행 클로저로 의존성을 주입합니다.
            NavigationHostView {
                // App 모듈만이 알고 있는 AppDI를 사용하여 의존성을 설정합니다.
                $0.recordRepository = AppDI.recordRepository
                $0.userRepository = AppDI.userRepository
                $0.markerRepository = AppDI.markerRepository
            }
            .environmentObject(NavigationViewModel())
        }
    }
}
