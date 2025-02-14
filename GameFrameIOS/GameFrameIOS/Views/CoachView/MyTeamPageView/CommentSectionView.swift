//
//  CommentSectionView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

struct CommentSectionView: View {
    var body: some View {
        // Comments section
        VStack(alignment: .leading) {
            Text("Comments").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top).padding(.bottom, 2)
            
            HStack (alignment: .top) {
                VStack {
                    Image(systemName: "person.crop.circle").resizable().frame(width: 30, height: 30).foregroundColor(.gray).aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .clipped().padding(.top, 2)
                }.padding(.trailing, 5)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Jane Doe").font(.subheadline).multilineTextAlignment(.leading)
                        Text("1 hour ago").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                    }.padding(.bottom, 4)
                    HStack {
                        Text("“Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt”").font(.caption).multilineTextAlignment(.leading)
                    }
                }
            }.padding(.bottom, 2)
            Divider()
            HStack (alignment: .top) {
                VStack {
                    Image(systemName: "person.crop.circle").resizable().frame(width: 30, height: 30).foregroundColor(.gray).aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .clipped().padding(.top, 2)
                }.padding(.trailing, 5)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Johnny ").font(.subheadline).multilineTextAlignment(.leading)
                        Text("30 minutes ago").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                    }.padding(.bottom, 4)
                    HStack {
                        Text("“Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt”").font(.caption).multilineTextAlignment(.leading)
                    }
                }
            }.padding(.top, 2)
        }.padding(.horizontal).padding(.bottom, 2)
        
        Divider()
        // Write a comment
        VStack {
            HStack {
                MessageInputView(messageHolder: "Write a comment...")
            }
            
        }
    }
}

#Preview {
    CommentSectionView()
}
