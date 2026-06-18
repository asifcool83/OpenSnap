#if DEBUG

import Foundation

enum DebugConfiguration {
    static let isDeveloperDiagnosticsEnabled = true
    static let diagnosticsRefreshIntervalNanoseconds: UInt64 = 1_000_000_000
}

#endif
