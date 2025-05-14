# CoordinatesApp

A SwiftUI iOS application that allows users to view, edit, and retrieve geographic coordinates (latitude and longitude).

## Features

- Display current geographic coordinates
- Manually edit latitude and longitude values
- Retrieve current device location using Core Location
- Input validation for coordinate ranges
- Error handling for location services
- Support for simulator testing with mock locations

## Project Structure

The application follows the MVVM architecture pattern and is organized as follows:

### Models
- `Coordinates`: Data structure for storing latitude and longitude values with formatting capabilities

### Views
- `ContentView`: Main view that orchestrates the app's UI components
- `CoordinatesDisplayView`: Displays the currently stored coordinates
- `CoordinatesEditView`: Form for editing latitude and longitude values with validation
- `SelectableTextField`: Custom text field that automatically selects all text when focused

### Managers
- `LocationManager`: Handles location services, permissions, and coordinate updates

## Technical Details

- Built with SwiftUI and Combine
- Uses Core Location for accessing device location
- Implements proper error handling for location services
- Provides real-time input validation
- Supports both portrait and landscape orientations
- Compatible with iOS 16.0 and later

## Usage

### Viewing Coordinates
The app displays the current coordinates at the top of the screen. When first launched, it attempts to retrieve the device's current location.

### Getting Current Location
Tap the "Get Current Location" button to request the device's current geographic coordinates. The app will handle permission requests automatically.

### Manually Editing Coordinates
1. Enter a latitude value between -90 and 90 degrees
2. Enter a longitude value between -180 and 180 degrees
3. Tap "Update Coordinates" to save the changes

### Error Handling
- The app displays appropriate error messages when location services are unavailable
- Input validation prevents invalid coordinate values
- Permission status is handled gracefully with user feedback

## Development

### Requirements
- Xcode 15.0 or later
- iOS 16.0+ deployment target
- Swift 5.9 or later

### Testing in Simulator
When running in the iOS Simulator, a "Use Mock Location" button is available to set predefined coordinates, as the simulator may not provide actual location data.

## License

Copyright © 2025 Paolo Barone. All rights reserved.
