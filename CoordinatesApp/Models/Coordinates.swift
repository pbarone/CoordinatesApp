import Foundation

/// A model representing geographic coordinates with latitude and longitude values.
struct Coordinates: Equatable {
    /// The latitude value in degrees, ranging from -90 (South) to 90 (North).
    var latitude: Double
    
    /// The longitude value in degrees, ranging from -180 (West) to 180 (East).
    var longitude: Double
    
    /// Returns the latitude formatted as a string with 2 decimal places.
    var formattedLatitude: String {
        return String(format: "%.2f", latitude)
    }
    
    /// Returns the longitude formatted as a string with 2 decimal places.
    var formattedLongitude: String {
        return String(format: "%.2f", longitude)
    }
    
    // MARK: - Equatable Implementation
    
    /// Compares two Coordinates instances for equality.
    /// - Parameters:
    ///   - lhs: Left-hand side Coordinates instance.
    ///   - rhs: Right-hand side Coordinates instance.
    /// - Returns: True if both latitude and longitude values are equal.
    static func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    // MARK: - Validation Methods
    
    /// Validates if a latitude value is within the valid range.
    /// - Parameter value: The latitude value to validate.
    /// - Returns: True if the value is between -90 and 90 degrees.
    static func isValidLatitude(_ value: Double) -> Bool {
        return value >= -90 && value <= 90
    }
    
    /// Validates if a longitude value is within the valid range.
    /// - Parameter value: The longitude value to validate.
    /// - Returns: True if the value is between -180 and 180 degrees.
    static func isValidLongitude(_ value: Double) -> Bool {
        return value >= -180 && value <= 180
    }
}
