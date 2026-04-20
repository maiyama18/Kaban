#if canImport(UIKit)
import SwiftUI
import UIKit

/// Abstraction that ``PhotoImage`` depends on for loading photos. Allows
/// the caller to swap in a mock loader for previews and tests without
/// relying on a DI framework.
public protocol PhotoImageLoading: Sendable {
    func requestImage(
        cloudIdentifier: String,
        displayType: PhotoLibraryClient.DisplayType
    ) async throws -> UIImage
}

extension PhotoLibraryClient: PhotoImageLoading {}

public struct DefaultPhotoImagePlaceholder: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
            ProgressView()
        }
    }
}

/// Displays a photo identified by a `PHCloudIdentifier` string.
///
/// The view does not apply any sizing or aspect ratio — the caller is
/// responsible for `.aspectRatio` / `.frame` modifiers as needed. While
/// the image is loading or on failure, the `placeholder` is shown.
public struct PhotoImage<Placeholder: View>: View {
    private let cloudIdentifier: String
    private let displayType: PhotoLibraryClient.DisplayType
    private let loader: any PhotoImageLoading
    private let placeholder: () -> Placeholder

    @State private var image: Image?

    public init(
        cloudIdentifier: String,
        displayType: PhotoLibraryClient.DisplayType,
        loader: any PhotoImageLoading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.cloudIdentifier = cloudIdentifier
        self.displayType = displayType
        self.loader = loader
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let image {
                image
                    .resizable()
            } else {
                placeholder()
            }
        }
        .task(id: cloudIdentifier) {
            image = nil
            do {
                let uiImage = try await loader.requestImage(
                    cloudIdentifier: cloudIdentifier,
                    displayType: displayType
                )
                image = Image(uiImage: uiImage)
            } catch {}
        }
    }
}

extension PhotoImage where Placeholder == DefaultPhotoImagePlaceholder {
    public init(
        cloudIdentifier: String,
        displayType: PhotoLibraryClient.DisplayType,
        loader: any PhotoImageLoading
    ) {
        self.init(
            cloudIdentifier: cloudIdentifier,
            displayType: displayType,
            loader: loader,
            placeholder: { DefaultPhotoImagePlaceholder() }
        )
    }
}

private struct NeverLoader: PhotoImageLoading {
    func requestImage(
        cloudIdentifier: String,
        displayType: PhotoLibraryClient.DisplayType
    ) async throws -> UIImage {
        try await Task.sleep(for: .seconds(60))
        throw CancellationError()
    }
}

private struct SolidColorLoader: PhotoImageLoading {
    let color: UIColor

    func requestImage(
        cloudIdentifier: String,
        displayType: PhotoLibraryClient.DisplayType
    ) async throws -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}

#Preview("Default placeholder") {
    PhotoImage(
        cloudIdentifier: "preview",
        displayType: .thumbnail(side: 256),
        loader: NeverLoader()
    )
    .aspectRatio(1, contentMode: .fit)
    .frame(width: 200)
}

#Preview("Custom placeholder") {
    PhotoImage(
        cloudIdentifier: "preview",
        displayType: .thumbnail(side: 256),
        loader: NeverLoader()
    ) {
        Color.blue.opacity(0.15)
            .overlay { Text("Loading…") }
    }
    .aspectRatio(1, contentMode: .fit)
    .frame(width: 200)
}

#Preview("Loaded image") {
    PhotoImage(
        cloudIdentifier: "preview",
        displayType: .thumbnail(side: 256),
        loader: SolidColorLoader(color: .systemTeal)
    )
    .aspectRatio(1, contentMode: .fit)
    .frame(width: 200)
}
#endif
