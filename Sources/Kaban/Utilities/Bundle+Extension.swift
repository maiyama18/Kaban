import Foundation

extension Bundle {
    public var appVersionText: String? {
        let shortVersion = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildVersion = object(forInfoDictionaryKey: "CFBundleVersion") as? String
        guard let shortVersion, !shortVersion.isEmpty else { return nil }
        guard let buildVersion, !buildVersion.isEmpty else { return shortVersion }
        return "\(shortVersion) (\(buildVersion))"
    }

    public var isAppStore: Bool {
        #if DEBUG
        return false
        #else
        return appStoreReceiptURL?.lastPathComponent != "sandboxReceipt"
        #endif
    }
}
