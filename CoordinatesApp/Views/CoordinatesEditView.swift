import SwiftUI

/// A view that provides a form for editing coordinates.
struct CoordinatesEditView: View {
    /// Binding to the latitude text value.
    @Binding var editLatitude: String
    
    /// Binding to the longitude text value.
    @Binding var editLongitude: String
    
    /// Callback function to execute when coordinates are updated.
    var onUpdate: () -> Void
    
    // MARK: - State Properties
    
    /// Error message for latitude input, nil if valid.
    @State private var latitudeError: String? = nil
    
    /// Error message for longitude input, nil if valid.
    @State private var longitudeError: String? = nil
    
    /// Focus state for the latitude text field.
    @FocusState private var isLatitudeFocused: Bool
    
    /// Focus state for the longitude text field.
    @FocusState private var isLongitudeFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Coordinates")
                .font(.headline)
            
            // Latitude input field
            VStack(alignment: .leading) {
                // Use SelectableTextField for automatic text selection and clear button
                SelectableTextField(
                    text: $editLatitude,
                    placeholder: "Latitude",
                    keyboardType: .decimalPad
                )
                .frame(height: 40)
                .focused($isLatitudeFocused)
                .onChange(of: editLatitude) { _, newValue in
                    validateLatitude(newValue)
                }
                .onChange(of: isLatitudeFocused) { _, isFocused in
                    // This ensures selection happens when focus changes programmatically
                    if isFocused {
                        // Small delay to ensure the field is ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                        }
                    }
                }
                
                // Error message for latitude
                if let error = latitudeError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                        .animation(.easeInOut, value: latitudeError)
                }
            }
            
            // Longitude input field
            VStack(alignment: .leading) {
                // Use SelectableTextField for automatic text selection and clear button
                SelectableTextField(
                    text: $editLongitude,
                    placeholder: "Longitude",
                    keyboardType: .decimalPad
                )
                .frame(height: 40)
                .focused($isLongitudeFocused)
                .onChange(of: editLongitude) { _, newValue in
                    validateLongitude(newValue)
                }
                .onChange(of: isLongitudeFocused) { _, isFocused in
                    // This ensures selection happens when focus changes programmatically
                    if isFocused {
                        // Small delay to ensure the field is ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                        }
                    }
                }
                
                // Error message for longitude
                if let error = longitudeError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                        .animation(.easeInOut, value: longitudeError)
                }
            }
            
            // Update button
            Button("Update Coordinates") {
                // Remove focus from text fields to dismiss keyboard
                isLatitudeFocused = false
                isLongitudeFocused = false
                
                // Validate before updating
                validateLatitude(editLatitude)
                validateLongitude(editLongitude)
                
                // Only update if no errors
                if latitudeError == nil && longitudeError == nil {
                    onUpdate()
                }
            }
            .padding(.vertical)
            .disabled(latitudeError != nil || longitudeError != nil)
            .opacity(latitudeError != nil || longitudeError != nil ? 0.6 : 1.0)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - Validation Methods
    
    /// Validates the latitude input and updates the error state.
    /// - Parameter value: The latitude value to validate as a string.
    private func validateLatitude(_ value: String) {
        // Check if it's a valid number
        guard let latitude = Double(value) else {
            latitudeError = "Please enter a valid number"
            return
        }
        
        // Check if it's in valid range
        guard Coordinates.isValidLatitude(latitude) else {
            latitudeError = "Latitude must be between -90 and 90"
            return
        }
        
        // Clear error if valid
        latitudeError = nil
    }
    
    /// Validates the longitude input and updates the error state.
    /// - Parameter value: The longitude value to validate as a string.
    private func validateLongitude(_ value: String) {
        // Check if it's a valid number
        guard let longitude = Double(value) else {
            longitudeError = "Please enter a valid number"
            return
        }
        
        // Check if it's in valid range
        guard Coordinates.isValidLongitude(longitude) else {
            longitudeError = "Longitude must be between -180 and 180"
            return
        }
        
        // Clear error if valid
        longitudeError = nil
    }
}

/// Preview provider for CoordinatesEditView.
#Preview {
    @State var lat = "37.77"
    @State var lon = "-122.41"
    
    return CoordinatesEditView(
        editLatitude: $lat,
        editLongitude: $lon,
        onUpdate: {}
    )
}
