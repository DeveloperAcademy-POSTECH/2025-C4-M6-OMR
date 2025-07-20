import SwiftUI

public extension DesignSystem {
    enum Color {
        // 예시 색상입니다. 실제 프로젝트에 맞게 이름을 변경하고,
        // Assets.xcassets에 해당 이름으로 색상을 추가해야 합니다.
        public static var primary: SwiftUI.Color {
            SwiftUI.Color("Primary", bundle: .module)
        }
        
        public static var secondary: SwiftUI.Color {
            SwiftUI.Color("Secondary", bundle: .module)
        }
        
        public static var background: SwiftUI.Color {
            SwiftUI.Color("Background", bundle: .module)
        }
    }
}