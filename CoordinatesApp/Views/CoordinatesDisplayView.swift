import SwiftUI

/// A view that displays the stored coordinates.
struct CoordinatesDisplayView: View {
    /// The coordinates to display.
    let coordinates: Coordinates
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Stored Coordinates")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Latitude:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(coordinates.formattedLatitude)
                        .font(.body)
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Longitude:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(coordinates.formattedLongitude)
                        .font(.body)
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .animation(.easeInOut, value: coordinates)
    }
}

/// Preview provider for CoordinatesDisplayView.
#Preview {
    CoordinatesDisplayView(coordinates: Coordinates(latitude: 37.77, longitude: -122.41))
}
