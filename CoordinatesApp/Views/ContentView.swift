import SwiftUI

/// The main view of the application.
/// This view coordinates all components and manages the overall state.
struct ContentView: View {
    // MARK: - State Properties
    
    /// The location manager that handles coordinates and location services.
    @StateObject private var locationManager = LocationManager()
    
    /// The current latitude value as a string for editing.
    @State private var editLatitude: String = "0.00"
    
    /// The current longitude value as a string for editing.
    @State private var editLongitude: String = "0.00"
    
    /// Controls whether an alert is currently displayed.
    @State private var showAlert = false
    
    /// The message to display in the alert.
    @State private var alertMessage = ""
    
    /// The title to display in the alert.
    @State private var alertTitle = "Coordinates Update"
    
    /// Focus state for the latitude text field.
    @FocusState private var isLatitudeFocused: Bool
    
    /// Focus state for the longitude text field.
    @FocusState private var isLongitudeFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Coordinates App")
                    .font(.largeTitle)
                
                // Stored coordinates display
                CoordinatesDisplayView(coordinates: locationManager.coordinates)
                
                // Error message display (if any)
                if let errorMessage = locationManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .animation(.easeInOut, value: locationManager.errorMessage)
                }
                
                // Coordinate editing form
                CoordinatesEditView(
                    editLatitude: $editLatitude,
                    editLongitude: $editLongitude,
                    onUpdate: updateCoordinates
                )
                
                // Get current location button
                Button(action: {
                    // Dismiss keyboard if active
                    isLatitudeFocused = false
                    isLongitudeFocused = false
                    
                    locationManager.requestLocation()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Get Current Location")
                        if locationManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(locationManager.isLoading)
                
                // For testing in simulator
                #if targetEnvironment(simulator)
                Button("Use Mock Location (Simulator)") {
                    locationManager.setMockLocation()
                }
                .padding(.top, 8)
                .font(.caption)
                #endif
                
                Spacer()
            }
            .padding()
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside of text fields
            isLatitudeFocused = false
            isLongitudeFocused = false
        }
        .onAppear {
            // Initialize edit fields with current coordinates
            editLatitude = locationManager.coordinates.formattedLatitude
            editLongitude = locationManager.coordinates.formattedLongitude
            
            // Request location when view appears
            locationManager.requestLocation()
        }
        // Use onReceive to observe the published property
        .onReceive(locationManager.$coordinates) { newCoordinates in
            // Update edit fields when coordinates change
            editLatitude = newCoordinates.formattedLatitude
            editLongitude = newCoordinates.formattedLongitude
        }
        .onReceive(locationManager.$lastError) { error in
            if let error = error {
                alertTitle = "Location Error"
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Helper Methods
    
    /// Updates the coordinates in the location manager from the edit fields.
    /// Validates input before updating and shows appropriate error messages.
    private func updateCoordinates() {
        guard let latitude = Double(editLatitude),
              let longitude = Double(editLongitude) else {
            alertTitle = "Input Error"
            alertMessage = "Please enter valid coordinates"
            showAlert = true
            return
        }
        
        // Validate coordinate ranges
        guard Coordinates.isValidLatitude(latitude) else {
            alertTitle = "Input Error"
            alertMessage = "Latitude must be between -90 and 90"
            showAlert = true
            return
        }
        
        guard Coordinates.isValidLongitude(longitude) else {
            alertTitle = "Input Error"
            alertMessage = "Longitude must be between -180 and 180"
            showAlert = true
            return
        }
        
        // Update coordinates in location manager
        locationManager.updateCoordinates(latitude: latitude, longitude: longitude)
        alertTitle = "Success"
        alertMessage = "Coordinates updated successfully"
        showAlert = true
    }
}

/// Preview provider for ContentView.
#Preview {
    ContentView()
}
