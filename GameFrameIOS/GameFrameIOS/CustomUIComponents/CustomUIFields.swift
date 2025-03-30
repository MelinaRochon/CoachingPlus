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
            .foregroundColor(.blue)
            .font(.footnote)
            .underline()
    }
}


