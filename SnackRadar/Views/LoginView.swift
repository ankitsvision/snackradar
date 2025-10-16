import SwiftUI
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    logoSection
                    
                    VStack(spacing: 20) {
                        roleToggle
                        
                        emailField
                        
                        passwordField
                        
                        actionButtons
                        
                        SignInWithAppleButton(.signIn) { request in
                            viewModel.handleSignInWithAppleRequest(request)
                        } onCompletion: { result in
                            Task {
                                await viewModel.handleSignInWithAppleCompletion(
                                    result,
                                    sessionViewModel: sessionViewModel
                                )
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.vertical, 40)
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("Password Reset", isPresented: $viewModel.showPasswordResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Send") {
                Task {
                    await viewModel.sendPasswordReset()
                }
            }
        } message: {
            Text("Enter your email address to receive a password reset link.")
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: 12) {
            Text("SnackRadar")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(AppColors.primaryBlue)
            
            Text("Find free food on campus")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.top, 40)
    }
    
    private var roleToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("I am a")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
            
            HStack(spacing: 0) {
                roleButton(role: .student)
                roleButton(role: .organizer)
            }
            .background(AppColors.lightGrey)
            .cornerRadius(8)
        }
    }
    
    private func roleButton(role: UserRole) -> some View {
        Button {
            viewModel.selectedRole = role
        } label: {
            Text(role.displayName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(viewModel.selectedRole == role ? .white : AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewModel.selectedRole == role ? AppColors.primaryBlue : Color.clear)
                .cornerRadius(8)
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
            
            TextField("Enter your email", text: $viewModel.email)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                if !viewModel.isSignUpMode {
                    Button("Forgot?") {
                        viewModel.showPasswordResetAlert = true
                    }
                    .font(.caption)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            
            SecureField("Enter your password", text: $viewModel.password)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(viewModel.isSignUpMode ? .newPassword : .password)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.handlePrimaryAction(sessionViewModel: sessionViewModel)
                }
            } label: {
                Text(viewModel.isSignUpMode ? "Sign Up" : "Sign In")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primaryBlue)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1.0 : 0.5)
            
            Button {
                viewModel.isSignUpMode.toggle()
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.isSignUpMode ? "Already have an account?" : "Don't have an account?")
                        .foregroundColor(AppColors.secondaryText)
                    Text(viewModel.isSignUpMode ? "Sign In" : "Sign Up")
                        .foregroundColor(AppColors.primaryBlue)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionViewModel())
    }
}
