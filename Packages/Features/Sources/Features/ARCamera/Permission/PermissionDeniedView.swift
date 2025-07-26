
import SwiftUI
import UIKit

// A view to show when permissions are denied
struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("권한 거부됨")
                .font(.headline)
            Text("이 기능을 사용하려면 설정에서 카메라 및 위치 접근 권한을 활성화해주세요.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
