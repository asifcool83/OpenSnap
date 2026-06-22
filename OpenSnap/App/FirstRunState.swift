import Foundation

@MainActor
final class FirstRunState: ObservableObject {
    private enum Key {
        static let completed = "OpenSnapFirstRunCompleted"
    }

    @Published private(set) var hasCompletedOnboarding: Bool
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasCompletedOnboarding = defaults.bool(forKey: Key.completed)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: Key.completed)
    }
}
