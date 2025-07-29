import SwiftUI
import CoreText

public struct DesignSystem {
    public static var TestColor: SwiftUI.Color {
        SwiftUI.Color("TestColor", bundle: .module)
    }
    
    /// DesignSystem 폰트들을 시스템에 등록합니다.
    /// 앱 시작 시 한 번만 호출하면 됩니다.
    public static func registerFonts() {
        // Bundle.module 디버깅
        print("🔍 Bundle.module 경로: \(Bundle.module.bundlePath)")
        print("🔍 Bundle.module 리소스들:")
        if let resourcePath = Bundle.module.resourcePath {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                for item in contents {
                    print("   - \(item)")
                }
            } catch {
                print("   ❌ 리소스 디렉토리 읽기 실패: \(error)")
            }
        }
        
        let fontNames = [
            "Pretendard-Black.otf",
            "Pretendard-Bold.otf", 
            "Pretendard-ExtraBold.otf",
            "Pretendard-ExtraLight.otf",
            "Pretendard-Light.otf",
            "Pretendard-Medium.otf",
            "Pretendard-Regular.otf",
            "Pretendard-SemiBold.otf",
            "Pretendard-Thin.otf"
        ]
        
        for fontName in fontNames {
            registerFont(named: fontName)
        }
    }
    
    private static func registerFont(named fontName: String) {
        // 확장자 제거 (예: "Pretendard-Black.otf" -> "Pretendard-Black")
        let fontNameWithoutExtension = fontName.replacingOccurrences(of: ".otf", with: "")
        
        guard let fontURL = Bundle.module.url(forResource: fontNameWithoutExtension, withExtension: "otf") else {
            print("⚠️ 폰트 파일을 찾을 수 없음: \(fontName)")
            print("🔍 찾는 경로: Bundle.module/\(fontNameWithoutExtension).otf")
            return
        }
        
        print("📁 폰트 파일 경로: \(fontURL.path)")
        
        guard let fontData = try? Data(contentsOf: fontURL),
              let provider = CGDataProvider(data: fontData as CFData),
              let font = CGFont(provider) else {
            print("⚠️ 폰트 로드 실패: \(fontName)")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("⚠️ 폰트 등록 실패: \(fontName) - \(error?.takeRetainedValue().localizedDescription ?? "알 수 없는 오류")")
        } else {
            print("✅ 폰트 등록 성공: \(fontName)")
        }
    }
}