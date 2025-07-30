import SwiftUI

public extension DesignSystem {
    enum Color {
        // 예시 색상입니다. 실제 프로젝트에 맞게 이름을 변경하고,
        // Assets.xcassets에 해당 이름으로 색상을 추가해야 합니다.
        public static var Prime: SwiftUI.Color {
            SwiftUI.Color("Prime", bundle: .module)
        }
        
        public static var Prime2: SwiftUI.Color {
            SwiftUI.Color("Prime2", bundle: .module)
        }
        
        public static var Prime3: SwiftUI.Color {
            SwiftUI.Color("Prime3", bundle: .module)
        }
        
        public static var Prime4: SwiftUI.Color {
            SwiftUI.Color("Prime4", bundle: .module)
        }
        
        public static var Prime5: SwiftUI.Color {
            SwiftUI.Color("Prime5", bundle: .module)
        }
        
        public static var Gray_01: SwiftUI.Color {
            SwiftUI.Color("Gray_01", bundle: .module)
        }
        
        public static var Gray_02: SwiftUI.Color {
            SwiftUI.Color("Gray_02", bundle: .module)
        }
        
        public static var Gray_03: SwiftUI.Color {
            SwiftUI.Color("Gray_03", bundle: .module)
        }
        
        public static var Gray_04: SwiftUI.Color {
            SwiftUI.Color("Gray_04", bundle: .module)
        }
        
        public static var Gray_black: SwiftUI.Color {
            SwiftUI.Color("Gray_black", bundle: .module)
        }
        
        public static var Gray_white: SwiftUI.Color {
            SwiftUI.Color("Gray_white", bundle: .module)
        }
        
        public static var Gray_Text: SwiftUI.Color {
            SwiftUI.Color("Gray_Text", bundle: .module)
        }
        
        public static var Gray_BG: SwiftUI.Color {
            SwiftUI.Color("Gray_BG", bundle: .module)
        }
        
        public static var Gray_Button: SwiftUI.Color {
            SwiftUI.Color("Gray_Button", bundle: .module)
        }
        
        public static var Gray_Button2: SwiftUI.Color {
            SwiftUI.Color("Gray_Button2", bundle: .module)
        }
        
        public static var Gray_Text2: SwiftUI.Color {
            SwiftUI.Color("Gray_Text2", bundle: .module)
        }
        
        public static var Gray_IC: SwiftUI.Color {
            SwiftUI.Color("Gray_IC", bundle: .module)
        }
        

    }
}

// UIKit 확장
extension DesignSystem.Color {
    public struct UIKit {
        public static var Prime: UIColor {
            UIColor(DesignSystem.Color.Prime)
        }
        
        public static var Prime2: UIColor {
            UIColor(DesignSystem.Color.Prime2)
        }
        
        public static var Prime3: UIColor {
            UIColor(DesignSystem.Color.Prime3)
        }
        
        public static var Prime4: UIColor {
            UIColor(DesignSystem.Color.Prime4)
        }
        
        public static var Prime5: UIColor {
            UIColor(DesignSystem.Color.Prime5)
        }
        
        public static var Gray_01: UIColor {
            UIColor(DesignSystem.Color.Gray_01)
        }
        
        public static var Gray_02: UIColor {
            UIColor(DesignSystem.Color.Gray_02)
        }
        
        public static var Gray_03: UIColor {
            UIColor(DesignSystem.Color.Gray_03)
        }
        
        public static var Gray_04: UIColor {
            UIColor(DesignSystem.Color.Gray_04)
        }
        
        public static var Gray_black: UIColor {
            UIColor(DesignSystem.Color.Gray_black)
        }
        
        public static var Gray_white: UIColor {
            UIColor(DesignSystem.Color.Gray_white)
        }
        
        public static var Gray_Text: UIColor {
            UIColor(DesignSystem.Color.Gray_Text)
        }
        
        public static var Gray_BG: UIColor {
            UIColor(DesignSystem.Color.Gray_BG)
        }
        
        public static var Gray_Button: UIColor {
            UIColor(DesignSystem.Color.Gray_Button)
        }
        
        public static var Gray_Button2: UIColor {
            UIColor(DesignSystem.Color.Gray_Button2)
        }
        
        public static var Gray_Text2: UIColor {
            UIColor(DesignSystem.Color.Gray_Text2)
        }
        
    }
}
