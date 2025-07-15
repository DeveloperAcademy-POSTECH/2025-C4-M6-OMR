import Combine
import Dependencies
import Domain
import Foundation

@MainActor
public final class MainViewModel: ObservableObject {
    // MARK: - State
    @Published public var motes: [Mote] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    // MARK: - Dependencies
    // Domain에 정의된 DependencyKey를 통해 실제 구현체를 주입받습니다.
    @Dependency(\.fetchNearbyMotesUseCase) private var fetchNearbyMotesUseCase

    public init() {}

    // MARK: - Public Methods
    public func loadNearbyMotes(center: Location, radius: Double) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedMotes = try await fetchNearbyMotesUseCase(
                    center: center,
                    radius: radius
                )
                self.motes = fetchedMotes
            } catch {
                self.errorMessage =
                    "데이터를 불러오는 데 실패했습니다: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}

// Helper to make String identifiable for the alert
extension String: Identifiable {
    public var id: String { self }
}
