//
//  ImagePicker.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-06.
//

import SwiftUI
import PhotosUI

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
