import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $settings.launchAtLogin)
            Toggle("Show Menu Bar Icon", isOn: $settings.showMenuBarIcon)
        }
        .padding()
        .frame(width: 360)
    }
}
