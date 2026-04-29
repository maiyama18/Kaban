import SwiftUI
import UIKit

/// SwiftUI wrapper for `UIActivityViewController`.
public struct ActivityScreen: UIViewControllerRepresentable {
    private let activityItems: [Any]

    /// Creates an activity screen for the given items.
    public init(activityItems: [Any]) {
        self.activityItems = activityItems
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
