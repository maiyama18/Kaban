import CoreLocation
import Foundation
import MapKit

public struct Placemark: Sendable, Equatable {
    public let name: String?
    public let fullAddress: String?
    public let shortAddress: String?
    public let cityName: String?
    public let regionName: String?
    public let countryRegionCode: String?
    public let latitude: Double
    public let longitude: Double

    public init(
        name: String? = nil,
        fullAddress: String? = nil,
        shortAddress: String? = nil,
        cityName: String? = nil,
        regionName: String? = nil,
        countryRegionCode: String? = nil,
        latitude: Double,
        longitude: Double
    ) {
        self.name = name
        self.fullAddress = fullAddress
        self.shortAddress = shortAddress
        self.cityName = cityName
        self.regionName = regionName
        self.countryRegionCode = countryRegionCode
        self.latitude = latitude
        self.longitude = longitude
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Returns the most descriptive short label available: `shortAddress` > `name` > `cityName`.
    public var shortDescription: String? {
        if let shortAddress, !shortAddress.isEmpty { return shortAddress }
        if let name, !name.isEmpty { return name }
        if let cityName, !cityName.isEmpty { return cityName }
        return nil
    }
}

extension Placemark {
    fileprivate init(_ mapItem: MKMapItem) {
        let coordinate = mapItem.location.coordinate
        let representations = mapItem.addressRepresentations
        self.init(
            name: mapItem.name,
            fullAddress: mapItem.address?.fullAddress
                ?? representations?.fullAddress(includingRegion: true, singleLine: false),
            shortAddress: mapItem.address?.shortAddress,
            cityName: representations?.cityName,
            regionName: representations?.regionName,
            countryRegionCode: representations?.region?.identifier,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}

public enum GeocodingError: Error, LocalizedError {
    case invalidInput
    case notFound
    case underlying(any Error)

    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return String(localized: "geocoding_error_invalid_input", bundle: .module)
        case .notFound:
            return String(localized: "geocoding_error_not_found", bundle: .module)
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

/// Reverse and forward geocoding via MapKit (`MKReverseGeocodingRequest` / `MKGeocodingRequest`).
///
/// Apple's geocoding service is rate-limited. Callers should debounce inputs
/// and cache results when invoking these methods frequently. Prefer at most
/// one in-flight request at a time for a given user interaction.
public struct GeocodingClient: Sendable {
    public var reverseGeocode: @Sendable (CLLocation) async throws -> Placemark
    public var forwardGeocode: @Sendable (String) async throws -> [Placemark]

    public init(
        reverseGeocode: @escaping @Sendable (CLLocation) async throws -> Placemark,
        forwardGeocode: @escaping @Sendable (String) async throws -> [Placemark]
    ) {
        self.reverseGeocode = reverseGeocode
        self.forwardGeocode = forwardGeocode
    }
}

extension GeocodingClient {
    public static let live: GeocodingClient = .init(
        reverseGeocode: { location in
            guard let request = MKReverseGeocodingRequest(location: location) else {
                throw GeocodingError.invalidInput
            }
            let items: [MKMapItem]
            do {
                items = try await request.mapItems
            } catch {
                throw GeocodingError.underlying(error)
            }
            guard let first = items.first else {
                throw GeocodingError.notFound
            }
            return Placemark(first)
        },
        forwardGeocode: { address in
            guard let request = MKGeocodingRequest(addressString: address) else {
                throw GeocodingError.invalidInput
            }
            let items: [MKMapItem]
            do {
                items = try await request.mapItems
            } catch {
                throw GeocodingError.underlying(error)
            }
            return items.map(Placemark.init)
        }
    )
}
