//
//  MessageInputView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

/**
 This is a message input component that includes the following:
 - A textfield to write the message
 - A send button
 This component is similar to the one seen in IMessage, when sending a text.
*/
struct MessageInputView: View {
    @State private var messageText: String = ""
    @State var messageHolder: String = ""

    var body: some View {
        HStack {
            TextField(messageHolder, text: $messageText)
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(Capsule()) // Rounded edges
            
            Button(action: {
                sendMessage()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25) // Adjust size
                    .foregroundColor(.blue)
            }
        }
        //.padding()
        /*.background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )*/
        .padding(.horizontal)
    }

    func sendMessage() {
        // Handle send message logic
        print("Message Sent: \(messageText)")
        messageText = "" // Clear text after sending
    }
}

#Preview {
    MessageInputView(messageHolder: "Type a message...")
}

