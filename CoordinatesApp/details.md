# CoordinatesApp - Technical Documentation

This document provides a detailed technical overview of the CoordinatesApp project, explaining its architecture, components, and implementation details.

## Architecture Overview

CoordinatesApp follows the MVVM (Model-View-ViewModel) architectural pattern:

- **Model**: Data structures that represent the core data (Coordinates)
- **View**: SwiftUI views that display information and handle user interaction
- **ViewModel**: Business logic and state management (LocationManager)

The app uses SwiftUI for the UI layer and CoreLocation for accessing device location services.

## Core Components

### Models

#### `Coordinates` (Models/Coordinates.swift)

A value type that represents geographic coordinates.

**Properties:**
- `latitude: Double` - The latitude value in degrees (-90 to 90)
- `longitude: Double` - The longitude value in degrees (-180 to 180)
- `formattedLatitude: String` - Formatted latitude string with 2 decimal places
- `formattedLongitude: String` - Formatted longitude string with 2 decimal places

**Methods:**
- `static func isValidLatitude(_ value: Double) -> Bool` - Validates if a latitude value is within range
- `static func isValidLongitude(_ value: Double) -> Bool` - Validates if a longitude value is within range
- `static func == (lhs: Coordinates, rhs: Coordinates) -> Bool` - Equatable implementation

**Usage:**
```swift
// Create coordinates
let coordinates = Coordinates(latitude: 37.77, longitude: -122.41)

// Access formatted values
let latString = coordinates.formattedLatitude // "37.77"

// Validate values
let isValid = Coordinates.isValidLatitude(100) // false
```

### Managers

#### `LocationManager` (Managers/LocationManager.swift)

Manages location services and coordinates data. Acts as the ViewModel in the MVVM pattern.

**Key Properties:**
- `@Published var coordinates: Coordinates` - Current coordinates, observable
- `@Published var isLoading: Bool` - Loading state indicator
- `@Published var errorMessage: String?` - User-friendly error message
- `@Published var locationStatus: CLAuthorizationStatus?` - Current authorization status
- `@Published var lastError: Error?` - Last error encountered

**Key Methods:**
- `func requestLocation()` - Requests the user's current location
- `func updateCoordinates(latitude:longitude:)` - Updates stored coordinates
- `func setMockLocation()` - Sets mock location data for testing

**State Management:**
- Tracks authorization request state
- Handles initial vs. subsequent requests differently
- Provides error handling and user feedback

**Usage:**
```swift
let locationManager = LocationManager()

// Request current location
locationManager.requestLocation()

// Manually update coordinates
locationManager.updateCoordinates(latitude: 37.77, longitude: -122.41)

// For testing
locationManager.setMockLocation()
```

### Views

#### `ContentView` (Views/ContentView.swift)

The main view of the application that coordinates all components.

**Key Properties:**
- `@StateObject private var locationManager` - Manages location state
- `@State private var editLatitude/editLongitude` - Editable coordinate values
- `@FocusState private var isLatitudeFocused/isLongitudeFocused` - Focus states for text fields

**Key Methods:**
- `func updateCoordinates()` - Validates and updates coordinates from form inputs

**Responsibilities:**
- Initializes the location manager
- Coordinates between display and edit views
- Handles user interactions and alerts
- Manages overall app state

#### `CoordinatesDisplayView` (Views/CoordinatesDisplayView.swift)

Displays the current coordinates in a formatted view.

**Properties:**
- `let coordinates: Coordinates` - The coordinates to display

**Features:**
- Displays formatted latitude and longitude
- Uses animations for smooth transitions when values change
- Uses numeric content transitions for number changes

#### `CoordinatesEditView` (Views/CoordinatesEditView.swift)

Provides a form for editing coordinates with validation.

**Key Properties:**
- `@Binding var editLatitude/editLongitude` - Bindings to editable values
- `var onUpdate: () -> Void` - Callback for when update button is pressed
- `@State private var latitudeError/longitudeError` - Validation error messages

**Key Methods:**
- `func validateLatitude/validateLongitude` - Validates input values

**Features:**
- Real-time validation with error messages
- Text selection on focus
- Clear buttons for text fields
- Disabled update button when inputs are invalid

#### `SelectableTextField` (Views/SelectableTextField.swift)

A custom UIViewRepresentable that wraps UITextField to provide features not available in SwiftUI's TextField.

**Properties:**
- `@Binding var text` - Binding to the text value
- `var placeholder` - Placeholder text
- `var keyboardType` - Keyboard type for the field

**Features:**
- Automatically selects all text when focused
- Includes a clear button
- Customizable appearance

**Implementation Details:**
- Uses UIViewRepresentable to bridge UIKit and SwiftUI
- Implements UITextFieldDelegate methods
- Handles text selection and changes

## Data Flow

1. **App Launch**:
   - `ContentView` creates a `LocationManager` instance
   - `LocationManager` initializes with default coordinates (0,0)
   - `ContentView` calls `locationManager.requestLocation()`

2. **Location Request**:
   - `LocationManager` checks location services availability
   - If not determined, requests authorization
   - When authorized, requests location updates
   - Updates `coordinates` property when location is received

3. **Displaying Coordinates**:
   - `ContentView` passes `locationManager.coordinates` to `CoordinatesDisplayView`
   - `CoordinatesDisplayView` formats and displays the values

4. **Editing Coordinates**:
   - User enters values in `CoordinatesEditView` text fields
   - Real-time validation occurs as user types
   - When "Update Coordinates" is tapped, `onUpdate` callback is triggered
   - `ContentView` validates and calls `locationManager.updateCoordinates()`
   - `LocationManager` updates its `coordinates` property
   - UI updates automatically through SwiftUI's binding system

5. **Error Handling**:
   - `LocationManager` sets `errorMessage` when errors occur
   - `ContentView` displays error messages and alerts
   - Specific handling for permission denied, location services disabled, etc.

## Key Features Implementation

### Location Permissions

The app handles location permissions through the `LocationManager`:

```swift
func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    locationStatus = status
    
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
        // Permission granted, request location
        if hasRequestedAuthorization {
            errorMessage = nil
            locationManager.requestLocation()
            hasRequestedAuthorization = false
        }
    case .denied, .restricted:
        // Permission denied, set coordinates to 0,0
        isLoading = false
        if hasRequestedAuthorization {
            errorMessage = "Location access denied. Please enable in Settings."
            updateCoordinates(latitude: 0.0, longitude: 0.0)
            hasRequestedAuthorization = false
        }
    // ...
    }
}
```

### Text Field Selection

The app implements automatic text selection using a custom `SelectableTextField`:

```swift
func textFieldDidBeginEditing(_ textField: UITextField) {
    // Select all text when the field gets focus
    textField.selectAll(nil)
}
```

### Validation

Coordinate validation is implemented in both the model and views:

```swift
// In Coordinates.swift
static func isValidLatitude(_ value: Double) -> Bool {
    return value >= -90 && value <= 90
}

// In CoordinatesEditView.swift
private func validateLatitude(_ value: String) {
    guard let latitude = Double(value) else {
        latitudeError = "Please enter a valid number"
        return
    }
    
    guard Coordinates.isValidLatitude(latitude) else {
        latitudeError = "Latitude must be between -90 and 90"
        return
    }
    
    latitudeError = nil
}
```

## Testing

### Simulator Testing

The app includes special handling for simulator environments:

```swift
#if targetEnvironment(simulator)
Button("Use Mock Location (Simulator)") {
    locationManager.setMockLocation()
}
.padding(.top, 8)
.font(.caption)
#endif
```

### Error Simulation

You can test error handling by:
1. Denying location permissions
2. Disabling location services
3. Using invalid coordinate values in the form

## Performance Considerations

- The app uses `@Published` properties for reactive updates
- Location requests are made only when needed
- UI updates are handled efficiently through SwiftUI's binding system
- Text field validation happens in real-time but doesn't block the UI

## Extension Points

The app can be extended in several ways:

1. **Map Integration**: Add a MapKit view to display the coordinates visually
2. **Location History**: Store and display previous locations
3. **Geocoding**: Add reverse geocoding to show address information
4. **Sharing**: Add functionality to share coordinates
5. **Unit Conversion**: Add support for different coordinate formats (DMS, etc.)

## Troubleshooting

Common issues and solutions:

1. **Location permissions denied**: The app will display an error message and set coordinates to (0,0)
2. **Invalid coordinate input**: The app will show validation errors and disable the update button
3. **Simulator location issues**: Use the "Use Mock Location" button or set a custom location in the simulator's Features menu

## Conclusion

CoordinatesApp demonstrates a clean implementation of location services in SwiftUI using the MVVM pattern. It handles permissions, user input, and error states gracefully while providing a simple and intuitive user interface.
