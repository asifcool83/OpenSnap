import Foundation
import Testing

struct MenuBarAppConfigurationTests {
    @Test func appIsConfiguredAsDocklessAgent() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let plistURL = repositoryRoot.appendingPathComponent("Configuration/Info.plist")
        let data = try Data(contentsOf: plistURL)
        let propertyList = try PropertyListSerialization.propertyList(from: data, format: nil)
        let dictionary = try #require(propertyList as? [String: Any])

        #expect(dictionary["LSUIElement"] as? Bool == true)
    }
}
