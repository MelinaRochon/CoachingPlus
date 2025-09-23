//
//  AIResponse.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-09-18.
//

import Foundation

struct AIResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: Message
    }
    struct Message: Decodable {
        let content: String
    }
}

func correctTranscript(transcript: String, roster: [String], completion: @escaping (String) -> Void) {
    let apiKey = Secrets.openAIKey
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    let rosterList = roster.joined(separator: ", ")
    let prompt = """
    Transcript: "\(transcript)"
    Roster: [\(rosterList)]
    Task: Task: Replace any word/phrase that is closest in sound to a roster name with that roster name.
    If multiple words are possible, pick the one from the roster. Output only the corrected transcript.
    """
    
    let body: [String: Any] = [
        "model": "gpt-4o-mini", // fast + cheap
        "messages": [["role": "user", "content": prompt]],
        "temperature": 0
    ]
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    let task = URLSession.shared.dataTask(with: request) { data, _, _ in
        if let data = data,
           let decoded = try? JSONDecoder().decode(AIResponse.self, from: data),
           let content = decoded.choices.first?.message.content {
            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            completion(transcript) // fallback
        }
    }
    task.resume()
}
