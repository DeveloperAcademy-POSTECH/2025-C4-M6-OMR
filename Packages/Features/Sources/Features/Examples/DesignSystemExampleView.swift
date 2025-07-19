import SwiftUI
import DesignSystem

// MARK: - DesignSystemExampleView
/// 디자인 시스템의 컴포넌트 사용 예시를 보여주는 뷰입니다.
public struct DesignSystemExampleView: View {
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // MARK: - Color & Font Examples
                VStack(alignment: .leading, spacing: 10) {
                    Text("Fonts & Colors (Dynamic Type 지원)")
                        .font(DesignSystem.Font.title1)
                    
                    Text("Headline: 헤드라인 폰트입니다.")
                        .font(DesignSystem.Font.headline)
                        .foregroundColor(DesignSystem.Color.primary)
                    
                    Text("Body: 본문 폰트입니다. 기기 설정에서 글자 크기를 바꿔보세요.")
                        .font(DesignSystem.Font.body)
                        .foregroundColor(DesignSystem.Color.secondary)
                    
                    Text("Caption: 캡션 폰트입니다.")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(DesignSystem.Color.secondary)
                    
                    Divider().padding(.vertical, 10)
                    
                    Text("Fixed Size: 이 텍스트는 19pt이며, 시스템 설정을 따르지 않습니다.")
                        .font(DesignSystem.Font.custom(size: 19, weight: .bold))
                        .foregroundColor(.red)
                }
                .padding()
                .background(DesignSystem.Color.background)
                .cornerRadius(10)
                
                // MARK: - Component Examples (향후 추가될 컴포넌트)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Components")
                        .font(DesignSystem.Font.title1)
                    
                    Text("향후 추가될 DSButton, DSCard 등의 컴포넌트 예시를 이곳에 추가할 수 있습니다.")
                        .font(DesignSystem.Font.body)
                    
                    // 예: DSButton 사용법 (주석 처리)
                    /*
                     DSButton(title: "Primary Button") {
                         print("Button Tapped!")
                     }
                     .buttonStyle(.primary)
                     */
                    
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Design System 예제")
    }
}

// MARK: - Preview
struct DesignSystemExampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DesignSystemExampleView()
        }
    }
}
