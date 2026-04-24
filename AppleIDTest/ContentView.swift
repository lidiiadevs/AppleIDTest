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
            
                Button(action: authenticateWithBiometrics) {
                    Text("Login with Touch/Face ID")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundStyle(Color.white)
                        .cornerRadius(7)
                }
            }
        }
        .alert(isPresented: $showError) {
            //show an alert if authentication fails
            Alert(title: Text("Authentication Error"), message: Text(errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
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
    
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        //check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authonticate with Face ID or Touch ID"
            //attemp to authenticate w/ biometrics
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                success, error in
                DispatchQueue.main.async {
                    if success {
                        //mark as authenticated
                        isAuthenticated = true
                    } else {
                        //show error with authenticated
                        errorMessage = error?.localizedDescription ?? "Biometric Failure"
                        showError = true
                    }
                }
            }
        } else { //show an error if biometric is not available
            errorMessage = error?.localizedDescription ?? "Biometric failure"
                       showError = true
        }
    }
}

#Preview {
    ContentView()
}
