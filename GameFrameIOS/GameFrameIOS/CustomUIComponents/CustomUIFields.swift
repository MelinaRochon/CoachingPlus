//
//  CustomUIFields.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-29.
//

import SwiftUI

/// A collection of custom UI fields for reusable components in your views.
struct CustomUIFields {
    
    /// Creates a styled text field with a placeholder.
    /// 
    /// - Parameters:
    ///   - placeholder: The placeholder text.
    ///   - text: A binding to the text input.
    /// - Returns: A customized `TextField` view.
    static func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 45)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.black)
    }
    
    /// Creates a styled disabled text field with a placeholder.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text.
    ///   - text: A binding to the text input.
    /// - Returns: A disabled and customized `TextField` view.
    static func disabledCustomTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 45)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.secondary)
            .disabled(true)
    }
    
    /// Creates a password field that can toggle between a `SecureField` and `TextField`.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text.
    ///   - text: A binding to the password input.
    ///   - showPassword: A binding to the boolean value that toggles the password visibility.
    /// - Returns: A customized password field view with an eye icon to toggle visibility.
    static func customPasswordField(_ placeholder: String, text: Binding<String>, showPassword: Binding<Bool>) -> some View {
        HStack {
            if showPassword.wrappedValue {
                TextField(placeholder, text: text).autocapitalization(.none)
            } else {
                SecureField(placeholder, text: text).autocapitalization(.none)
            }
            
            Button(action: { showPassword.wrappedValue.toggle() }) {
                Image(systemName: showPassword.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 45)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
    }
    
    /// Creates a styled "Create Account" button.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text.
    /// - Returns: A customized `HStack` representing a "Create Account" button.
    static func createAccountButton(_ placeholder: String) -> some View {
        styledHStack(content: {
            Text(placeholder)
                .font(.body).bold()
        }, background: .black)
    }
    
    /// Creates a styled "Sign in Account" button.
    ///
    /// - Returns: A customized `HStack` representing a "Create Account" button.
    static func signInAccountButton(_ placeholder: String) -> some View {
        styledHStack {
            Text(placeholder)
                .font(.body).bold()
            Image(systemName: "arrow.right")
        }
    }
    
    /// A reusable style for an `HStack` with specific styling, for a button.
    ///
    /// - Parameters:
    ///   - content: A closure that returns the content inside the `HStack`.
    /// - Returns: A styled `HStack` view.
    static func styledHStack<Content: View>(@ViewBuilder content: () -> Content, background: Color? = .black) -> some View {
        HStack {
            content()
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    /// A reusable style for a `text link` with specific styling, acting just as a normal link.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text.
    /// - Returns: A styled `Link` view.

    static func linkButton(_ placeholder: String) -> some View {
        Text(placeholder)
            .foregroundColor(.red)
            .font(.footnote)
            .underline()
    }
    
    /// A styled rectangle to be used as a preview for game videos.
    /// - Returns: A `Rectangle` view with a gray background, rounded corners, and a specific size.
    static func gameVideoPreviewStyle() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 110, height: 60)
            .cornerRadius(10)
    }
    
    /// A loading spinner with a given placeholder text, used to indicate loading status.
    /// - Parameter placeholder: A `String` that will be displayed as the text for the loading spinner.
    /// - Returns: A `VStack` containing a `ProgressView` styled as a circular spinner.
    static func loadingSpinner(_ placeholder: String) -> some View {
        VStack() {
            ProgressView(placeholder)
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .tint(.gray)
        }
    }
    
    /// A reusable SwiftUI view that displays a horizontal label with a red SF Symbol icon and text.
    ///
    /// - Parameters:
    ///   - text: The text to display next to the icon.
    ///   - systemImage: The name of the SF Symbol to use as the icon.
    ///
    /// - Returns: A `View` containing an `HStack` with a red icon and a label.
    @ViewBuilder
    static func imageLabel(text: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .frame(width: 25)
                .foregroundStyle(.red) // Red icon
            Text(text)
                .foregroundStyle(.primary) // Default text color
        }
    }
}


