import SwiftUI

struct PermissionRequestView: View {
    @ObservedObject var manager: PermissionsManager

    var body: some View {
        VStack(spacing: 20) {
            Text("카메라 접근 권한 필요")
                .font(.headline)
            Text("AR 경험을 위해 카메라 접근 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("권한 부여") {
                Task {
                    await manager.request()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}