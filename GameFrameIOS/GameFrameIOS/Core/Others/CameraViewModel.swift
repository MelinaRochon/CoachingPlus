//
//  CameraViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-10.
//

import AVKit

final class CameraViewModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    @Published var isRecording = false
    @Published var recordedVideoURL: URL? // <-- Add this!
    
    var onRecordingFinished: ((URL) -> Void)?
    
    /// Add a background queue
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    func configure() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            // Input
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else { return }
            self.session.addInput(input)
            
            // Output
            if self.session.canAddOutput(self.movieOutput) {
                self.session.addOutput(self.movieOutput)
            }
            
            self.session.commitConfiguration()
            
            // Start session on background queue
            self.session.startRunning()
        }
    }
    
    func toggleRecording() {
        if isRecording {
            movieOutput.stopRecording()
        } else {
            // Generate a unique filename each time to avoid overwriting
            let filename = UUID().uuidString + ".mov"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            
            // Set the correct video orientation
            if let connection = movieOutput.connection(with: .video) {
                connection.videoOrientation = currentVideoOrientation()
            }
            
            movieOutput.startRecording(to: tempURL, recordingDelegate: self)
        }
        isRecording.toggle()
    }
    
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    // Called when recording finishes
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        DispatchQueue.main.async {
            self.recordedVideoURL = outputFileURL
            print("🎥 Finished recording: \(outputFileURL)")
            
            // Notify the parent
            self.onRecordingFinished?(outputFileURL)
        }
    }
}
