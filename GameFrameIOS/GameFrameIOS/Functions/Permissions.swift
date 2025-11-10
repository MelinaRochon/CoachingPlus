//
//  Permissions.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-10.
//

import AVKit

func checkCameraPermission(completion: @escaping (Bool) -> Void) {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .authorized:
        // Already granted
        completion(true)
        
    case .notDetermined:
        // Request permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
        
    case .denied, .restricted:
        // Access denied or restricted
        completion(false)
        
    @unknown default:
        completion(false)
    }
}

func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .authorized:
        completion(true)
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    case .denied, .restricted:
        completion(false)
    @unknown default:
        completion(false)
    }
}
