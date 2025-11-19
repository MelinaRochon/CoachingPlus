//
//  WatchToIOSConnector.swift
//  GameFrameWatch Watch App
//
//  Created by Mélina Rochon on 2025-11-10.
//

import WatchConnectivity
import WatchKit

final class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    private var lastHeartbeat: Date = Date() // Last heartbeat sent from the phone. To know if app was killed
    private var timer: Timer?
    
    @Published var isGameRecordingOn = false
    @Published var gameAbruptlyStoppedAlert = false
    private var activationCompletion: (() -> Void)?

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Monitor Heartbeats
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.checkHeartbeat()
        }
    }

    private func checkHeartbeat() {
        let interval = Date().timeIntervalSince(lastHeartbeat)
        if interval > 3.0 && self.isGameRecordingOn { // 3s timeout
            self.stopRecordingDueToPhoneClosure()
        }
    }

    private func stopRecordingDueToPhoneClosure() {
        isGameRecordingOn = false
        gameAbruptlyStoppedAlert = true
        
        // Force the recording to stop
        _ = WatchAudioRecorder.shared.stopRecording()
        print("Stopped recording: no heartbeat from phone")
    }

        // MARK: - WCSessionDelegate
    
    func waitForActivation(completion: @escaping () -> Void) {
        // If already activated, just call completion
        if session.activationState == .activated {
            completion()
        } else {
            // Otherwise, store closure to call later
            activationCompletion = completion
        }
    }
    
    // TODO: There's a bug when the apple watch is connected and an audio game is started..... if save it, the app seems to crash
    
//    func sendRecordingToIOS(fileURL: URL, recordingStart: Date, recordingEnd: Date) {
    func sendRecordingToIOS(fileURL: URL, recordingStart: Date, recordingEnd: Date, transcript: String) {

        guard session.isReachable else {
            print("iPhone not reachable")
            return
        }
        
        // Data to be transfered to iPhone
        let metadata: [String: Any] = [
            "recording_start_time": recordingStart,
            "recording_end_time": recordingEnd,
            "test_transcript": transcript
        ]

        waitForActivation {
            print("Sending message....")
            
            #if targetEnvironment(simulator)
            // Code for simulator
            self.session.sendMessage(metadata, replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
            #else
            // Code for real device
            print("file url = \(fileURL)")
            self.session.transferFile(fileURL, metadata: metadata) //["type": "audio"])
            print("File transfer started after activation!")
            #endif
        }
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Reachable? \(session.isReachable)")  // Must be true
        if activationState == .activated {
            requestCurrentGameState()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // --- 1. Existing logic (keep EXACTLY as is)
            if let isGameOn = message["gameRecordingOn"] as? Bool {
                self.isGameRecordingOn = isGameOn
            }
                        
            if let _ = message["heartbeat"] as? Bool {
                self.lastHeartbeat = Date()
                // Optionally, could log receipt
                print("Heartbeat received")
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if !session.isReachable {
            print("📴 iPhone app is no longer reachable.")
            stopRecordingDueToPhoneClosure()
        } else {
            print("📱 iPhone app is reachable again.")
            requestCurrentGameState()
        }
    }
    
    
    func sendVersionToPhone() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        WCSession.default.sendMessage(
            ["watchAppVersion": version],
            replyHandler: nil,
            errorHandler: nil
        )
    }
    
//    private func stopRecordingDueToPhoneClosure() {
//        DispatchQueue.main.async {
//            // Example: stop any active recording or timer
//            self.isGameRecordingOn = false
//            self.gameAbruptlyStoppedAlert = true
//            // Optional: show an alert or message
//        }
//    }
    
    func deleteRecordingsDirectory() {
        let fileManager = FileManager.default
        
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory,
                                                in: .userDomainMask).first else {
            return
        }
        
        let recordingsDir = appSupport.appendingPathComponent("recordings", isDirectory: true)
        
        // If the folder exists, remove it completely
        if fileManager.fileExists(atPath: recordingsDir.path) {
            do {
                try fileManager.removeItem(at: recordingsDir)
                print("Deleted recordings directory")
            } catch {
                print("Failed to delete recordings directory:", error)
            }
        }
    }
    
    func session(_ session: WCSession,
                 didFinish fileTransfer: WCSessionFileTransfer,
                 error: Error?) {

        if error == nil {
            // Delete only the individual completed file
            try? FileManager.default.removeItem(at: fileTransfer.file.fileURL)
        }

        // Try cleanup again — maybe this was the last file
        cleanupIfSafe()
    }
    
    func cleanupIfSafe() {
        let session = WCSession.default
        
        // ❗ If transfers are still happening, DO NOT cleanup
        if !session.outstandingFileTransfers.isEmpty {
            print("Transfers still in progress, delaying cleanup…")
            return
        }
        
        // ❗ SAFE to delete recordings
        deleteRecordingsDirectory()
    }
    
    func requestCurrentGameState() {
        guard session.isReachable else {
            print("iPhone not reachable — cannot request state")
            return
        }

        session.sendMessage(["requestState": true], replyHandler: { reply in
            DispatchQueue.main.async {
                if let currentState = reply["gameRecordingOn"] as? Bool {
                    self.isGameRecordingOn = currentState
                    print("Synced game state from iPhone:", currentState)
                }
            }
        }, errorHandler: { error in
            print("Failed to request state:", error.localizedDescription)
        })
    }
}
