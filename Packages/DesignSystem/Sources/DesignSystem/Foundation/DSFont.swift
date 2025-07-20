import SwiftUI

public extension DesignSystem {
    /// `DesignSystem.Font`는 Dynamic Type을 지원합니다.
    /// 각 폰트는 시스템 텍스트 스타일과 연동되어,
    /// 사용자의 기기 설정에 따라 크기가 자동으로 조절됩니다.
    enum Font {
        // Pretendard 폰트 이름을 정확하게 사용해야 합니다.
        private static let bold = "Pretendard-Bold"
        private static let regular = "Pretendard-Regular"
        private static let medium = "Pretendard-Medium"
        private static let light = "Pretendard-Light"
        
        /// Bold, 28pt (at large size)
        public static var title1: SwiftUI.Font {
            .custom(bold, size: 28, relativeTo: .largeTitle)
        }
        
        /// Bold, 22pt (at large size)
        public static var title2: SwiftUI.Font {
            .custom(bold, size: 22, relativeTo: .title2)
        }
        
        /// Bold, 17pt (at large size)
        public static var headline: SwiftUI.Font {
            .custom(bold, size: 17, relativeTo: .headline)
        }
        
        /// Regular, 17pt (at large size)
        public static var body: SwiftUI.Font {
            .custom(regular, size: 17, relativeTo: .body)
        }
        
        /// Regular, 15pt (at large size)
        public static var callout: SwiftUI.Font {
            .custom(regular, size: 15, relativeTo: .callout)
        }
        
        /// Regular, 12pt (at large size)
        public static var caption: SwiftUI.Font {
            .custom(regular, size: 12, relativeTo: .caption)
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
            default:
                fontName = regular
            }
            return .custom(fontName, size: size)
        }
    }
}
