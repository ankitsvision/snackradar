import Foundation
import FirebaseAuth
import AuthenticationServices

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .userNotFound:
            return "No account found with this email."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknownError(let message):
            return message
        }
    }
}

class AuthService {
    static let shared = AuthService()
    private let auth = Auth.auth()
    
    private init() {}
    
    var currentUser: FirebaseAuth.User? {
        return auth.currentUser
    }
    
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws -> FirebaseAuth.User {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idToken,
            rawNonce: nonce
        )
        
        do {
            let result = try await auth.signIn(with: credential)
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    private func mapAuthError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
            return .unknownError(error.localizedDescription)
        }
        
        switch errorCode {
        case .wrongPassword, .invalidCredential:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .unknownError(error.localizedDescription)
        }
    }
}
