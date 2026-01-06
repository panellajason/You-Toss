import SwiftUI

struct AuthView: View {
    enum Mode {
        case login
        case signup
    }

    @StateObject private var authVM = AuthViewModel()
    @State private var mode: Mode = .login

    @State private var isLoading = false

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""

    // 🔹 Validation / Alert state
    @State private var showAlert = false
    @State private var alertMessage = ""

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
            Button(action: handleSubmit) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                } else {
                    Text(mode == .login ? "Log In" : "Sign Up")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            // Bottom toggle
            HStack(spacing: 4) {
                Text(
                    mode == .login
                    ? "Don't have an account?"
                    : "Already have an account?"
                )
                .foregroundColor(.secondary)

                Button(mode == .login ? "Sign up" : "Log in") {
                    withAnimation(.easeInOut) {
                        isLoading = false
                        mode = mode == .login ? .signup : .login
                    }
                }
                .fontWeight(.semibold)
            }
            .font(.footnote)

            Spacer()
        }
        .padding()
        .onChange(of: authVM.errorMessage) { error in
            guard let error else { return }
            if error.contains("auth credential is malformed") {
                alertMessage = "Email and/or password is incorrect."
            } else {
                alertMessage = error
            }
            showAlert = true
            isLoading = false
        }
        // 🔹 Popup
        .alert("Something went wrong", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Validation + Submit

    private func handleSubmit() {
        // Trim whitespace
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        if mode == .signup && trimmedUsername.isEmpty {
            alertMessage = "Please enter a username."
            showAlert = true
            return
        }

        if trimmedEmail.isEmpty {
            alertMessage = "Please enter your email."
            showAlert = true
            return
        }

        if trimmedPassword.isEmpty {
            alertMessage = "Please enter your password."
            showAlert = true
            return
        }

        // ✅ All good — proceed
        isLoading = true
        if mode == .login {
            authVM.signIn(email: trimmedEmail, password: trimmedPassword) {_ in 
                isLoading = false
            }
        } else {
            authVM.checkIfUsernameExists(username: username) { exists in
                if exists {
                    isLoading = false
                    alertMessage = "Username already exists."
                    showAlert = true
                } else {
                    authVM.signUp(email: trimmedEmail, password: trimmedPassword,username: trimmedUsername) {_ in 
                        isLoading = false
                    }
                }
            }
        }
    }
}
