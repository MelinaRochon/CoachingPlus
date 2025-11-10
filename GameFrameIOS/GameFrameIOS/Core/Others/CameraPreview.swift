//
//  CameraPreview.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-10.
//

import SwiftUI
import AVKit

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = currentVideoOrientation()
        
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            // 1. Make layer fill the container
            context.coordinator.previewLayer?.frame = UIScreen.main.bounds // uiView.bounds
            
            // 2. Match video orientation to device
            if let connection = context.coordinator.previewLayer?.connection,
               connection.isVideoOrientationSupported {
                connection.videoOrientation = currentVideoOrientation()
            }
        }
    }
    
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
