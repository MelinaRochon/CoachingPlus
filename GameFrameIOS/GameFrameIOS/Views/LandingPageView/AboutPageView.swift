//
//  AboutPageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

/** This SwiftUI view represents the About Page of the app.
  It provides a simple interface with a brief "About Us" section and a placeholder
  for further content that will be implemented in the future.

  Currently, the view displays a welcome message and a note indicating that the
  "About Us" section will be added in a future release.

  The view includes:
  - A navigation view for future enhancements, such as adding a navigation bar or additional pages.
  - A vertically stacked layout with some spacing between elements.
  - A scrollable text area for displaying the "About Us" content and other related information.
 */
struct AboutPageView: View {
    var body: some View {
        NavigationView {
            
            VStack(spacing: 20) {
                
                ScrollView {
                    Text("Hey there!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("About us...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // TODO: - Implement the `about us` section in a future release...
                }
            }
        }
    }
}

#Preview {
    AboutPageView()
}
