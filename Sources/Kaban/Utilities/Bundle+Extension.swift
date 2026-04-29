import Foundation

extension Bundle {
    /// App version text in the form `CFBundleShortVersionString (CFBundleVersion)`.
    public var appVersionText: String? {
        let shortVersion = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildVersion = object(forInfoDictionaryKey: "CFBundleVersion") as? String
        guard let shortVersion, !shortVersion.isEmpty else { return nil }
        guard let buildVersion, !buildVersion.isEmpty else { return shortVersion }
        return "\(shortVersion) (\(buildVersion))"
    }

    /// Whether the bundle appears to be running from an App Store receipt.
    public var isAppStore: Bool {
        #if DEBUG
        return false
        #else
        return appStoreReceiptURL?.lastPathComponent != "sandboxReceipt"
        #endif
    }
}
