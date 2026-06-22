import Foundation

/// The single source of truth for app, build, and host identity.
struct BuildInfo: Equatable, Sendable {
    private enum Key {
        static let appName = "CFBundleDisplayName"
        static let fallbackAppName = "CFBundleName"
        static let version = "CFBundleShortVersionString"
        static let build = "CFBundleVersion"
        static let gitCommit = "OpenSnapGitCommit"
        static let gitBranch = "OpenSnapGitBranch"
    }

    let appName: String
    let version: String
    let buildNumber: String
    let gitCommit: String?
    let branch: String?
    let macOSVersion: String
    let cpuArchitecture: String

    static var current: BuildInfo {
        BuildInfo(
            infoDictionary: Bundle.main.infoDictionary ?? [:],
            macOSVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            cpuArchitecture: currentArchitecture
        )
    }

    init(
        infoDictionary: [String: Any],
        macOSVersion: String,
        cpuArchitecture: String
    ) {
        appName = Self.string(for: Key.appName, in: infoDictionary)
            ?? Self.string(for: Key.fallbackAppName, in: infoDictionary)
            ?? "OpenSnap"
        version = Self.string(for: Key.version, in: infoDictionary) ?? "Unavailable"
        buildNumber = Self.string(for: Key.build, in: infoDictionary) ?? "Unavailable"
        gitCommit = Self.string(for: Key.gitCommit, in: infoDictionary)
        branch = Self.string(for: Key.gitBranch, in: infoDictionary)
        self.macOSVersion = macOSVersion
        self.cpuArchitecture = cpuArchitecture
    }

    var versionAndBuild: String {
        "\(version) (\(buildNumber))"
    }

    private static func string(for key: String, in dictionary: [String: Any]) -> String? {
        guard let value = dictionary[key] as? String else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty,
              !trimmed.hasPrefix("$(") else {
            return nil
        }

        return trimmed
    }

    private static var currentArchitecture: String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "Unknown"
        #endif
    }
}
