//
//  SignInView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct AuthView: View {
    enum Mode {
        case login
        case signup
    }

    @StateObject private var authVM = AuthViewModel()
    @State private var mode: Mode = .login

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // Image / Logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            // Header
            Text(mode == .login ? "Welcome Back" : "Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(
                mode == .login
                ? "Sign in to continue"
                : "Sign up to get started"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)

            // Username (Sign Up only)
            if mode == .signup {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            // Email
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            // Password
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            // Primary button
            Button(action: {
                if mode == .login {
                    authVM.signIn(email: email, password: password)
                    
                } else {
                    authVM.signUp(email: email, password: password, username: username)
                }
            }) {
                Text(mode == .login ? "Log In" : "Sign Up")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            // Bottom toggle
            HStack(spacing: 4) {
                Text(
                    mode == .login
                    ? "Don't have an account?"
                    : "Already have an account?"
                )
                .foregroundColor(.secondary)

                Button(
                    mode == .login ? "Sign up" : "Log in"
                ) {
                    withAnimation(.easeInOut) {
                        mode = mode == .login ? .signup : .login
                    }
                }
                .fontWeight(.semibold)
            }
            .font(.footnote)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    AuthView()
}
