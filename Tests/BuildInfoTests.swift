import Testing
@testable import OpenSnap

struct BuildInfoTests {
    @Test func readsBundleAndSystemIdentity() {
        let buildInfo = BuildInfo(
            infoDictionary: [
                "CFBundleDisplayName": "OpenSnap Beta",
                "CFBundleShortVersionString": "0.2.0-beta.1",
                "CFBundleVersion": "42",
                "OpenSnapGitCommit": "abc1234",
                "OpenSnapGitBranch": "feature/beta",
                "OpenSnapBuildDate": "2026-06-19T08:00:00Z"
            ],
            macOSVersion: "Version 15.5 (Build 24F74)",
            cpuArchitecture: "arm64"
        )

        #expect(buildInfo.appName == "OpenSnap Beta")
        #expect(buildInfo.version == "0.2.0-beta.1")
        #expect(buildInfo.buildNumber == "42")
        #expect(buildInfo.gitCommit == "abc1234")
        #expect(buildInfo.branch == "feature/beta")
        #expect(buildInfo.buildDate == "2026-06-19T08:00:00Z")
        #expect(buildInfo.macOSVersion == "Version 15.5 (Build 24F74)")
        #expect(buildInfo.cpuArchitecture == "arm64")
        #expect(buildInfo.versionAndBuild == "0.2.0-beta.1 (42)")
    }

    @Test func omitsUnavailableOptionalMetadata() {
        let buildInfo = BuildInfo(
            infoDictionary: [
                "CFBundleName": "OpenSnap",
                "OpenSnapGitCommit": "$(OPEN_SNAP_GIT_COMMIT)",
                "OpenSnapGitBranch": " ",
                "OpenSnapBuildDate": ""
            ],
            macOSVersion: "macOS",
            cpuArchitecture: "x86_64"
        )

        #expect(buildInfo.appName == "OpenSnap")
        #expect(buildInfo.version == "Unavailable")
        #expect(buildInfo.buildNumber == "Unavailable")
        #expect(buildInfo.gitCommit == nil)
        #expect(buildInfo.branch == nil)
        #expect(buildInfo.buildDate == nil)
    }
}
