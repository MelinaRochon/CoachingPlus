//
//  WatchToIOSConnector.swift
//  GameFrameWatch Watch App
//
//  Created by Mélina Rochon on 2025-11-10.
//

import WatchConnectivity

final class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    @Published var isGameRecordingOn = false
    @Published var gameAbruptlyStoppedAlert = false
    private var activationCompletion: (() -> Void)?

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        
        if WCSession.isSupported() {
            print("session is supported")
            session.delegate = self
            session.activate()
        } else {
            print("session is NOT supported")

        }
    }
    
    func waitForActivation(completion: @escaping () -> Void) {
        // If already activated, just call completion
        if session.activationState == .activated {
            completion()
        } else {
            // Otherwise, store closure to call later
            activationCompletion = completion
        }
    }


//    func sendAudioFile(url: URL) {
//        guard WCSession.default.isReachable else {
//            print("iPhone not reachable")
//            return
//        }
//        WCSession.default.transferFile(url, metadata: ["type": "audio"])
//        print("Audio file sent to iPhone.")
//    }
    
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
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let isGameOn = message["gameRecordingOn"] as? Bool {
                self.isGameRecordingOn = isGameOn // Whether the game recording started or ended
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if !session.isReachable {
            print("📴 iPhone app is no longer reachable.")
            handlePhoneDisconnected()
        } else {
            print("📱 iPhone app is reachable again.")
        }
    }
    
    private func handlePhoneDisconnected() {
        DispatchQueue.main.async {
            // Example: stop any active recording or timer
            self.isGameRecordingOn = false
            self.gameAbruptlyStoppedAlert = true
            // Optional: show an alert or message
        }
    }
}
