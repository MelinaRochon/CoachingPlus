//
//  AudioRecordingView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI

struct AudioRecordingView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Transcripts added")) {
                        HStack (alignment: .center) {
                            Text("hh:mm:ss").bold().font(.headline)
                            Text("Transcript: “Lorem ipsum dolor sit amet, consectetur adipiscing...”").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2)
                            Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                        }
                        HStack (alignment: .center) {
                            Text("hh:mm:ss").bold().font(.headline)
                            Text("Transcript: “Lorem ipsum dolor sit amet, consectetur adipiscing...”").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2)
                            Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                        }
                        HStack (alignment: .center) {
                            Text("hh:mm:ss").bold().font(.headline)
                            Text("Transcript: “Lorem ipsum dolor sit amet, consectetur adipiscing...”").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2)
                            Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                        }
                    }
                }.listStyle(.plain)
                // Audio Recording Button
                Spacer()
                RecordingButtonView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Text("End Recording")
                    }
                }
            }
        }
    }
}

#Preview {
    AudioRecordingView()
}
