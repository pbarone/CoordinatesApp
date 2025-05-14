import Foundation
import CoreLocation
import Combine

/// Manages location services and coordinates data for the application.
/// This class handles location permissions, requests, and error handling.
class LocationManager: NSObject, ObservableObject {
    /// The Core Location manager used to access device location.
    private let locationManager = CLLocationManager()
    
    // MARK: - Published Properties
    
    /// The current coordinates, published to notify observers when changed.
    @Published var coordinates: Coordinates
    
    /// The current authorization status for location services.
    @Published var locationStatus: CLAuthorizationStatus?
    
    /// The last error encountered during location operations.
    @Published var lastError: Error?
    
    /// Indicates whether a location request is in progress.
    @Published var isLoading = false
    
    /// User-friendly error message for display in the UI.
    @Published var errorMessage: String?
    
    // MARK: - State Tracking
    
    /// Tracks whether we've explicitly requested authorization from the user.
    private var hasRequestedAuthorization = false
    
    /// Tracks whether this is the initial location request on app launch.
    private var isInitialRequest = true
    
    // MARK: - Initialization
    
    /// Initializes the location manager with default settings.
    override init() {
        // Initialize with default coordinates (0,0)
        self.coordinates = Coordinates(latitude: 0.0, longitude: 0.0)
        
        super.init()
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check initial authorization status without requesting
        self.locationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    /// Requests the user's current location.
    /// This method handles the entire flow of checking permissions,
    /// requesting authorization if needed, and fetching the location.
    func requestLocation() {
        // Clear previous errors
        lastError = nil
        errorMessage = nil
        isLoading = true
        
        // Check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            let authStatus = locationManager.authorizationStatus
            
            switch authStatus {
            case .notDetermined:
                // First request authorization, then location will be requested in the callback
                hasRequestedAuthorization = true
                // Use DispatchQueue.main.async to avoid UI unresponsiveness warning
                DispatchQueue.main.async {
                    self.locationManager.requestWhenInUseAuthorization()
                }
            case .authorizedWhenInUse, .authorizedAlways:
                // Already authorized, request location directly
                locationManager.requestLocation()
            case .denied, .restricted:
                // Handle denied permission
                isLoading = false
                errorMessage = "Location access denied. Please enable in Settings."
                updateCoordinates(latitude: 0.0, longitude: 0.0)
            @unknown default:
                isLoading = false
                errorMessage = "Unknown authorization status."
                updateCoordinates(latitude: 0.0, longitude: 0.0)
            }
        } else {
            isLoading = false
            errorMessage = "Location services are disabled. Please enable them in Settings."
            // Set coordinates to 0,0 as specified in requirements
            updateCoordinates(latitude: 0.0, longitude: 0.0)
        }
    }
    
    /// Updates the stored coordinates with new latitude and longitude values.
    /// - Parameters:
    ///   - latitude: The new latitude value.
    ///   - longitude: The new longitude value.
    func updateCoordinates(latitude: Double, longitude: Double) {
        coordinates = Coordinates(latitude: latitude, longitude: longitude)
    }
    
    /// Sets mock location data for testing or simulator use.
    /// This method updates coordinates to San Francisco's location.
    func setMockLocation() {
        // San Francisco coordinates as an example
        updateCoordinates(latitude: 37.7749, longitude: -122.4194)
        isLoading = false
        errorMessage = nil
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    /// Called when new location data is available.
    /// - Parameters:
    ///   - manager: The location manager that generated the update.
    ///   - locations: An array of CLLocation objects containing the location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        errorMessage = nil
        
        if let location = locations.last {
            updateCoordinates(latitude: location.coordinate.latitude,
                             longitude: location.coordinate.longitude)
        }
    }
    
    /// Called when an error occurs during location updates.
    /// - Parameters:
    ///   - manager: The location manager that encountered the error.
    ///   - error: The error that occurred.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        lastError = error
        
        // Only show error if not the initial request
        if !isInitialRequest {
            // Handle specific location errors
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    errorMessage = "Location access denied. Please enable in Settings."
                    updateCoordinates(latitude: 0.0, longitude: 0.0)
                case .network:
                    errorMessage = "Network error. Please check your connection."
                default:
                    // For simulator or other errors, use mock location
                    #if targetEnvironment(simulator)
                    setMockLocation()
                    errorMessage = nil // Don't show error for simulator
                    #else
                    errorMessage = "Error getting location: \(error.localizedDescription)"
                    updateCoordinates(latitude: 0.0, longitude: 0.0)
                    #endif
                }
            } else {
                errorMessage = "Error getting location: \(error.localizedDescription)"
                // Set coordinates to 0,0 as specified in requirements
                updateCoordinates(latitude: 0.0, longitude: 0.0)
            }
        } else {
            // For initial request errors, just set coordinates without showing error
            #if targetEnvironment(simulator)
            setMockLocation()
            #else
            updateCoordinates(latitude: 0.0, longitude: 0.0)
            #endif
            isInitialRequest = false
        }
    }
    
    /// Called when the authorization status for the application changes.
    /// - Parameter manager: The location manager that reported the change.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        locationStatus = status
        
        // Clear the initial request flag
        isInitialRequest = false
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // If permission granted and we were waiting for authorization, request location
            if hasRequestedAuthorization {
                errorMessage = nil // Clear any previous error messages
                locationManager.requestLocation()
                hasRequestedAuthorization = false
            }
        case .denied, .restricted:
            isLoading = false
            // Only show error if we explicitly requested authorization
            if hasRequestedAuthorization {
                errorMessage = "Location access denied. Please enable in Settings."
                updateCoordinates(latitude: 0.0, longitude: 0.0)
                hasRequestedAuthorization = false
            }
        case .notDetermined:
            // Still waiting for user decision
            break
        @unknown default:
            isLoading = false
            errorMessage = "Unknown authorization status."
        }
    }
}
