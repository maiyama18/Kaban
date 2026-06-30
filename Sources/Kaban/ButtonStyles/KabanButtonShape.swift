import SwiftUI

/// Shape used by Kaban button styles.
public enum KabanButtonShape: Sendable {
    case roundedRectangle
    case capsule

    internal var shape: AnyShape {
        switch self {
        case .roundedRectangle:
            AnyShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .capsule:
            AnyShape(Capsule())
        }
    }
}
