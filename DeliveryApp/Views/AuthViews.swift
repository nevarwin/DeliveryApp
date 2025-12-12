//
//  AuthViews.swift
//  DeliveryApp
//
//  Simple onboarding and login screens.
//

import SwiftUI
import AuthenticationServices

struct RootView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            if !appViewModel.isOnboarded {
                OnboardingView()
            } else if !appViewModel.isLoggedIn {
                LoginView()
            } else {
                ContentView()
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .foregroundStyle(.orange)
            
            Text("Welcome to Local Eats")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Discover nearby favorites, add them to your cart, and get them delivered fast.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                appViewModel.completeOnboarding()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 8) {
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                Text("Welcome Back")
                    .font(.largeTitle.bold())
                
                Text("Log in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Email/Password Form
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .email)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .password)
            }
            .padding(.horizontal)
            
            // Login Button
            Button {
                focusedField = nil
                appViewModel.login(email: email, password: password)
            } label: {
                Text("Log In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)
            .disabled(email.isEmpty || password.isEmpty)
            
            // Error Message
            if let errorMessage = appViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray.opacity(0.3))
                
                Text("OR")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .padding(.horizontal, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray.opacity(0.3))
            }
            .padding(.horizontal)
            
            // OAuth Buttons
            VStack(spacing: 12) {
                // Apple Sign In
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    },
                    onCompletion: { result in
                        switch result {
                            case .success(let authorization):
                                appViewModel.signInWithApple(authorization)
                            case .failure(let error):
                                appViewModel.errorMessage = error.localizedDescription
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding(.horizontal)
                
                // Google Sign In
                Button {
                    appViewModel.signInWithGoogle()
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Continue with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Sign Up Link (Optional)
            HStack {
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)
                Button("Sign Up") {
                    // Navigate to sign up
                }
                .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
        .onSubmit {
            if focusedField == .email {
                focusedField = .password
            } else if focusedField == .password {
                appViewModel.login(email: email, password: password)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppViewModel())
}

