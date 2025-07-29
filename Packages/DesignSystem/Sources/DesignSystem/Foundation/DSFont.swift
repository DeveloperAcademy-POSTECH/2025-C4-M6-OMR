import SwiftUI

public extension DesignSystem {
    /// `DesignSystem.Font`는 Dynamic Type을 지원합니다.
    /// 각 폰트는 시스템 텍스트 스타일과 연동되어,
    /// 사용자의 기기 설정에 따라 크기가 자동으로 조절됩니다.
    enum Font {
        // Pretendard 폰트 이름을 정확하게 사용해야 합니다.
        private static let black = "Pretendard-Black"
        private static let bold = "Pretendard-Bold"
        private static let extraBold = "Pretendard-ExtraBold"
        private static let extraLight = "Pretendard-ExtraLight"
        private static let light = "Pretendard-Light"
        private static let medium = "Pretendard-Medium"
        private static let regular = "Pretendard-Regular"
        private static let semiBold = "Pretendard-SemiBold"
        private static let thin = "Pretendard-Thin"

        // MARK: - Title 1
        public enum Title1 {
            public static var semibold: SwiftUI.Font {
                .custom(Font.semiBold, size: 24, relativeTo: .largeTitle)
            }
        }
        
        // MARK: - Title 2
        public enum Title2 {
            public static var semibold: SwiftUI.Font {
                .custom(Font.semiBold, size: 18, relativeTo: .title)
            }
            
            public static var bold: SwiftUI.Font {
                .custom(Font.bold, size: 18, relativeTo: .title)
            }
        }
        
        // MARK: - Headline
        public enum Headline {
            public static var semibold: SwiftUI.Font {
                .custom(Font.semiBold, size: 14, relativeTo: .headline)
            }
            
            public static var medium: SwiftUI.Font {
                .custom(Font.medium, size: 14, relativeTo: .headline)
            }
            
            public static var regular: SwiftUI.Font {
                .custom(Font.regular, size: 14, relativeTo: .headline)
            }
        }
        
        // MARK: - Title 3
        public enum Title3 {
            public static var semibold: SwiftUI.Font {
                .custom(Font.semiBold, size: 16, relativeTo: .title3)
            }
            
            public static var medium: SwiftUI.Font {
                .custom(Font.medium, size: 16, relativeTo: .title3)
            }
            
            public static var bold: SwiftUI.Font {
                .custom(Font.bold, size: 16, relativeTo: .title3)
            }
        }
        
        // MARK: - Large Title
        public enum LargeTitle {
            public static var semibold: SwiftUI.Font {
                .custom(Font.semiBold, size: 20, relativeTo: .largeTitle)
            }
        }
        
        // MARK: - Body
        public enum Body {
            public static var regular: SwiftUI.Font {
                .custom(Font.regular, size: 12, relativeTo: .body)
            }
        }
        
        // MARK: - Navigation Title
        public enum NavigationTitle {
            public static var bold: SwiftUI.Font {
                .custom(Font.bold, size: 28, relativeTo: .largeTitle)
            }
        }
        
        /// **[예외 처리용]** Dynamic Type을 사용하지 않는 고정 크기 폰트를 반환합니다.
        /// - Parameters:
        ///   - size: 고정 폰트 크기
        ///   - weight: 폰트 굵기 (기본값: .regular)
        public static func custom(size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            let fontName: String
            switch weight {
            case .bold:
                fontName = bold
            case .light:
                fontName = light
            case .medium:
                fontName = medium
            case .semibold:
                fontName = semiBold
            default:
                fontName = regular
            }
            return .custom(fontName, size: size)
        }
    }
}

// UIFont 확장 추가
extension DesignSystem.Font {
    public struct UIKit {
        // Pretendard
        private static let black = "Pretendard-Black"
        private static let bold = "Pretendard-Bold"
        private static let extraBold = "Pretendard-ExtraBold"
        private static let extraLight = "Pretendard-ExtraLight"
        private static let light = "Pretendard-Light"
        private static let medium = "Pretendard-Medium"
        private static let regular = "Pretendard-Regular"
        private static let semiBold = "Pretendard-SemiBold"
        private static let thin = "Pretendard-Thin"
        
        public struct Title1 {
            public static let semibold = UIFont(name: UIKit.semiBold, size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        }
        
        public struct Title2 {
            public static let semibold = UIFont(name: UIKit.semiBold, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
            public static let bold = UIFont(name: UIKit.bold, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        }
        
        public struct Title3 {
            public static let semibold = UIFont(name: UIKit.semiBold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
            public static let medium = UIFont(name: UIKit.medium, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
            public static let bold = UIFont(name: UIKit.bold, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        }
        
        public struct Headline {
            public static let semibold = UIFont(name: UIKit.semiBold, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
            public static let medium = UIFont(name: UIKit.medium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
            public static let regular = UIFont(name: UIKit.regular, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        
        public struct LargeTitle {
            public static let semibold = UIFont(name: UIKit.semiBold, size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        }
        
        public struct Body {
            public static let regular = UIFont(name: UIKit.regular, size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
        }
        
        public struct NavigationTitle {
            public static let bold = UIFont(name: UIKit.bold, size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        }
        
        public static func custom(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
            let fontName: String
            switch weight {
            case .bold:
                fontName = bold
            case .light:
                fontName = light
            case .medium:
                fontName = medium
            case .semibold:
                fontName = semiBold
            case .black:
                fontName = black
            case .thin:
                fontName = thin
            default:
                fontName = regular
            }
            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
}
