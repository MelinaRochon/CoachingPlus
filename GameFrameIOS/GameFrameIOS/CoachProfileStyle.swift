//
//  CoachProfileStyle.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-06.
//

import SwiftUI

extension Image {
    
    /**
     Style for images -> is used for profile pictures
     **/
    func profileImageStyle() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .clipped()
            .overlay(){
                ZStack{
                    Image(systemName: "camera.fill").foregroundColor(.gray).offset(y: 30)
                    
                    // border
                    RoundedRectangle(cornerRadius: 100).stroke(.white, lineWidth: 4)
                }
            }
    }
}
