import SafariServices
import SwiftUI

/// SwiftUI wrapper for `SFSafariViewController`.
public struct SafariScreen: UIViewControllerRepresentable {
    private let url: URL

    /// Creates a Safari screen for the given URL.
    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
