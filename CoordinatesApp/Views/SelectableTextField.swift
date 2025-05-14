import SwiftUI
import UIKit

/// A custom text field that automatically selects all text when focused and includes a clear button.
/// This component bridges UIKit's UITextField with SwiftUI to provide functionality not available in SwiftUI's TextField.
struct SelectableTextField: UIViewRepresentable {
    /// The binding to the text value.
    @Binding var text: String
    
    /// The placeholder text to display when the field is empty.
    var placeholder: String
    
    /// The keyboard type to use for this text field.
    var keyboardType: UIKeyboardType
    
    /// Creates the UITextField instance and configures its initial state.
    /// - Parameter context: The context in which the text field is created.
    /// - Returns: A configured UITextField instance.
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.systemGray6
        
        // Add clear button that always appears
        textField.clearButtonMode = .always
        
        return textField
    }
    
    /// Updates the UITextField when the SwiftUI state changes.
    /// - Parameters:
    ///   - uiView: The UITextField to update.
    ///   - context: The context in which the update occurs.
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    /// Creates a coordinator to handle the UITextField's delegate methods.
    /// - Returns: A new Coordinator instance.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Coordinator class to handle UITextField delegate methods.
    class Coordinator: NSObject, UITextFieldDelegate {
        /// Reference to the parent SelectableTextField.
        var parent: SelectableTextField
        
        /// Initializes the coordinator with a reference to its parent.
        /// - Parameter parent: The SelectableTextField that owns this coordinator.
        init(_ parent: SelectableTextField) {
            self.parent = parent
        }
        
        /// Called when the text field becomes the first responder.
        /// - Parameter textField: The text field that gained focus.
        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Select all text when the field gets focus
            textField.selectAll(nil)
        }
        
        /// Called when the text selection changes in the text field.
        /// - Parameter textField: The text field whose selection changed.
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
