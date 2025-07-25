import SwiftUI

public struct DSButton: View {
    public var body: some View {
        // This view might not be directly used, but rather its nested ButtonStyle
        EmptyView()
    }

    public struct Primary: ButtonStyle {
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        }
    }
}
