//
//  ContentView.swift
//  AppleIDTest
//
//  Created by Lidiia Diachkovskaia on 4/23/26.
//

import SwiftUI
import AuthenticationServices //allows sign in with apple
import LocalAuthentication //for biometric login

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var showError = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isAuthenticated {
                Text("Welcome Back")
                    .font(.largeTitle)
                //logic for taking the user for the rest of the app would be here
                Button("Sign Out") {
                    isAuthenticated = false
                }
                
            } else {
                SignInWithAppleButton(.signIn) {
                    request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    //handle request of the apple sign in process
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding()
            }
        }
        .padding()
    }
    
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let _ = authorization.credential as? ASAuthorizationAppleIDCredential {
                //mark user as authenticated if the apple id sign in is valid
                isAuthenticated = true
            }
        case .failure(let error):
            //capture and display any errors from the apple id sign in
            errorMessage = error.localizedDescription
            showError = true
            print("Apple ID error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
