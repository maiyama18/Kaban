#if canImport(UIKit)
import Foundation
import Photos
import UIKit

/// Stores `UIImage` into the user's Photo Library and reads images back by the
/// iCloud-stable `PHCloudIdentifier`.
///
/// Callers are responsible for requesting `PHPhotoLibrary` authorization
/// before invoking `saveImage(_:)`. `requestImage(cloudIdentifier:displayType:)`
/// requires at least read authorization.
///
/// When iCloud Photos is disabled on the device, `saveImage(_:)` will throw
/// ``PhotoLibraryError/cloudIdentifierUnavailable``. The caller may fall back
/// to storing the `localIdentifier` temporarily if desired.
public actor PhotoLibraryClient: NSObject {
    public enum DisplayType: Sendable, Equatable {
        /// Optimized square thumbnail delivered via `PHCachingImageManager`.
        case thumbnail(side: CGFloat)
        /// Full-resolution original image.
        case original
    }

    public enum PhotoLibraryError: Error, LocalizedError {
        case saveFailed
        case cloudIdentifierUnavailable
        case assetNotFound
        case imageRequestFailed(any Error)

        public var errorDescription: String? {
            switch self {
            case .saveFailed:
                return String(localized: "photo_library_error_save_failed", bundle: .module)
            case .cloudIdentifierUnavailable:
                return String(localized: "photo_library_error_cloud_identifier_unavailable", bundle: .module)
            case .assetNotFound:
                return String(localized: "photo_library_error_asset_not_found", bundle: .module)
            case .imageRequestFailed(let error):
                return error.localizedDescription
            }
        }
    }

    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    private let photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()

    private var pendingLocalIdentifier: String?
    private var cloudIdentifierContinuation: CheckedContinuation<String, any Error>?

    public override init() {
        super.init()
        photoLibrary.register(self)
    }

    /// Saves the given image to the Photo Library and waits for its
    /// `PHCloudIdentifier` to resolve. Returns the cloud identifier as
    /// `String` suitable for cross-device persistence.
    ///
    /// Throws ``PhotoLibraryError/cloudIdentifierUnavailable`` if the cloud
    /// identifier cannot be resolved within 3 seconds (typically when iCloud
    /// Photos is disabled).
    public func saveImage(_ image: UIImage) async throws -> String {
        var localIdentifier: String?
        do {
            try await photoLibrary.performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
            }
        } catch {
            throw PhotoLibraryError.saveFailed
        }
        guard let localIdentifier else {
            throw PhotoLibraryError.saveFailed
        }
        self.pendingLocalIdentifier = localIdentifier

        do {
            return try await withTimeout(for: .seconds(3)) { [weak self] in
                guard let self else { throw CancellationError() }
                return try await self.awaitCloudIdentifier()
            }
        } catch is TimeoutError {
            resumePendingIdentifier(throwing: PhotoLibraryError.cloudIdentifierUnavailable)
            throw PhotoLibraryError.cloudIdentifierUnavailable
        } catch {
            resumePendingIdentifier(throwing: error)
            throw error
        }
    }

    /// Loads the image for the given `PHCloudIdentifier` string.
    public func requestImage(cloudIdentifier: String, displayType: DisplayType) async throws -> UIImage {
        guard let asset = asset(forCloudIdentifier: cloudIdentifier) else {
            throw PhotoLibraryError.assetNotFound
        }
        return try await requestImage(asset: asset, displayType: displayType)
    }

    private func awaitCloudIdentifier() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.cloudIdentifierContinuation = continuation
        }
    }

    private func resumePendingIdentifier(throwing error: any Error) {
        cloudIdentifierContinuation?.resume(throwing: error)
        cloudIdentifierContinuation = nil
        pendingLocalIdentifier = nil
    }

    private func resolvePendingIdentifier() {
        guard
            let pendingLocalIdentifier,
            let cloudIdentifierContinuation
        else { return }

        let mappings = photoLibrary.cloudIdentifierMappings(forLocalIdentifiers: [pendingLocalIdentifier])
        guard
            let result = mappings[pendingLocalIdentifier],
            case .success(let cloudIdentifier) = result
        else { return }

        cloudIdentifierContinuation.resume(returning: cloudIdentifier.stringValue)
        self.cloudIdentifierContinuation = nil
        self.pendingLocalIdentifier = nil
    }

    private func asset(forCloudIdentifier cloudIdentifier: String) -> PHAsset? {
        let phCloudIdentifier = PHCloudIdentifier(stringValue: cloudIdentifier)
        guard
            let result = photoLibrary.localIdentifierMappings(for: [phCloudIdentifier])[phCloudIdentifier],
            case .success(let localIdentifier) = result,
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
        else {
            return nil
        }
        return asset
    }

    private func requestImage(asset: PHAsset, displayType: DisplayType) async throws -> UIImage {
        let targetSize: CGSize =
            switch displayType {
            case .thumbnail(let side):
                CGSize(width: side, height: side)
            case .original:
                CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            }
        let contentMode: PHImageContentMode =
            switch displayType {
            case .thumbnail: .aspectFill
            case .original: .default
            }

        return try await withCheckedThrowingContinuation { c in
            var continuation: CheckedContinuation<UIImage, any Error>? = c

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: .highQuality()
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation?.resume(throwing: PhotoLibraryError.imageRequestFailed(error))
                    continuation = nil
                    return
                }
                if let cancelled = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue, cancelled {
                    continuation?.resume(throwing: CancellationError())
                    continuation = nil
                    return
                }
                if let image {
                    continuation?.resume(returning: image)
                } else {
                    continuation?.resume(throwing: PhotoLibraryError.assetNotFound)
                }
                continuation = nil
            }
        }
    }
}

extension PhotoLibraryClient: PHPhotoLibraryChangeObserver {
    nonisolated public func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { await self.resolvePendingIdentifier() }
    }
}

extension PHImageRequestOptions {
    fileprivate static func highQuality() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        return options
    }
}
#endif
