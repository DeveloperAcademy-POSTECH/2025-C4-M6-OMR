import SwiftUI

public struct DesignSystem {
    public static var TestColor: SwiftUI.Color {
        SwiftUI.Color("TestColor", bundle: .module)
    }
}