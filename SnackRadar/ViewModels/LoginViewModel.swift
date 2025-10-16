import Foundation
import AuthenticationServices
import CryptoKit

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var selectedRole: UserRole = .student
    @Published var isSignUpMode = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showPasswordResetAlert = false
    
    private let authService = AuthService.shared
    private var currentNonce: String?
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    func handlePrimaryAction(sessionViewModel: SessionViewModel) async {
        guard isFormValid else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            if isSignUpMode {
                try await signUp(sessionViewModel: sessionViewModel)
            } else {
                try await signIn()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func signIn() async throws {
        _ = try await authService.signIn(email: email, password: password)
    }
    
    private func signUp(sessionViewModel: SessionViewModel) async throws {
        let user = try await authService.signUp(email: email, password: password)
        try await sessionViewModel.createUserProfile(
            uid: user.uid,
            email: email,
            role: selectedRole
        )
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>, sessionViewModel: SessionViewModel) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            switch result {
            case .success(let authorization):
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                      let nonce = currentNonce,
                      let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AuthError.unknownError("Unable to fetch identity token")
                }
                
                let user = try await authService.signInWithApple(idToken: idTokenString, nonce: nonce)
                
                if let email = appleIDCredential.email ?? user.email {
                    do {
                        _ = try await sessionViewModel.userRepository.getUserProfile(uid: user.uid)
                    } catch RepositoryError.documentNotFound {
                        try await sessionViewModel.createUserProfile(
                            uid: user.uid,
                            email: email,
                            role: selectedRole
                        )
                    }
                }
                
            case .failure(let error):
                throw error
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func sendPasswordReset() async {
        guard !email.isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter your email address."
                showError = true
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await authService.resetPassword(email: email)
            await MainActor.run {
                errorMessage = "Password reset email sent. Please check your inbox."
                showError = true
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
