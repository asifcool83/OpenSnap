import SwiftUI

struct PermissionRow: View {
    let title: String
    let explanation: String
    let isGranted: Bool
    let requestAccess: () -> Void
    let openSettings: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "circle.dashed")
                .font(.title2)
                .foregroundStyle(isGranted ? Color.green : Color.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(isGranted ? "Allowed" : "Permission required")

            Spacer(minLength: 12)

            if isGranted {
                Text("Allowed")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    Button("Allow…", action: requestAccess)
                        .buttonStyle(.borderedProminent)
                    Button("Open Settings", action: openSettings)
                        .buttonStyle(.link)
                        .font(.caption)
                }
            }
        }
    }
}
