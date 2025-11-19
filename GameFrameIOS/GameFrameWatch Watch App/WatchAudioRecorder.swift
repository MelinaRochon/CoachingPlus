//
//  AudioRecorder.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-11.
//

import Foundation
import AVFoundation
import WatchConnectivity

class WatchAudioRecorder: NSObject, AVAudioRecorderDelegate, ObservableObject {
    static let shared = WatchAudioRecorder()
    
    private var audioRecorder: AVAudioRecorder?
    var recordingStartTime: Date?
    var recordingEndTime: Date?
    
    @Published var isRecording = false
    @Published var currentDuration: TimeInterval = 0
    
    private var timer: Timer?
    
    // MARK: - Start Recording
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            
            let fileName = UUID().uuidString + ".m4a"
            let url = FileManager.default.urls(for: .applicationSupportDirectory,in: .userDomainMask)[0]
                .appendingPathComponent("recordings", isDirectory: true)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

            let fileURL = url.appendingPathComponent(fileName)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            recordingStartTime = Date()
            isRecording = true
            
            startTimer()
            
            print("🎙️ Started recording: \(fileURL)")
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Stop Recording
    func stopRecording() -> URL? {
        guard isRecording, let recorder = audioRecorder else { return nil }
        
        recorder.stop()
        timer?.invalidate()
        recordingEndTime = Date()
        isRecording = false
        
        if let fileURL = recorder.url as URL? {
            return fileURL
        }
        
        return nil
    }
    
    func resetValues() {
        audioRecorder = nil
        recordingStartTime = nil

    }
    
    // MARK: - Timer to update duration
    private func startTimer() {
        currentDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRecording, let start = self.recordingStartTime else { return }
            self.currentDuration = Date().timeIntervalSince(start)
        }
    }
}

