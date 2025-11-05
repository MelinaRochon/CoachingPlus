//
//  ImagePicker.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-06.
//

import SwiftUI
import PhotosUI

/**  This SwiftUI view is a wrapper around the PHPickerViewController, which allows users to select
  an image from their photo library. It leverages the `UIViewControllerRepresentable` protocol
  to integrate UIKit’s PHPickerViewController into the SwiftUI framework. The picker filters to
  show only images, and once the user selects an image, it is returned through a `Binding` to
  the parent view.

  Key Components:
  - `ImagePicker`: A SwiftUI view that presents the PHPickerViewController when used.
  - `Coordinator`: A custom class that acts as a delegate for the PHPickerViewController,
    handling the completion of image selection and updating the bound `UIImage?` value.
  - The `makeUIViewController(context:)` function creates and configures the `PHPickerViewController`
    with image filtering enabled.
  - The `picker(_:didFinishPicking:)` function is called once the user selects an image,
    which is then passed back to the parent view via the `@Binding` property.

  This file makes it easy to integrate image selection functionality into a SwiftUI app while
  leveraging UIKit components via SwiftUI's `UIViewControllerRepresentable`.
*/

// Inspired by Daniel Budd's tutorial
// Link to tutorial: https://www.youtube.com/watch?v=zjqmphN33sg
// Wrap in a UIViewControllerRepresentable
struct ImagePicker: UIViewControllerRepresentable {
    // Create binding used to return selected image
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// Create a coordinator to pull the sequence of events together
class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    
    func picker (_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                self.parent.image = image as? UIImage}
        }
    }
}
