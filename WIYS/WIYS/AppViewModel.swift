import Foundation
import SwiftUI
import AuthenticationServices
import UIKit

@MainActor
final class AppViewModel: ObservableObject {
    @Published var appFlow: AppFlow = .onboarding
    @Published var session: AuthSession?
    @Published var userProfile: UserProfile?
    @Published var soulmateHistory: [SoulmateVisual] = []
    @Published var currentVisual: SoulmateVisual?
    @Published var currentMatchResult: SoulmateMatchResult?
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?

    private let authService: AuthService
    private let soulmateService: SoulmateService
    private var appleSignInCoordinator: AppleSignInCoordinator?

    init(authService: AuthService, soulmateService: SoulmateService) {
        self.authService = authService
        self.soulmateService = soulmateService
    }

    var quoteOfTheDay: SoulmateQuote {
        soulmateService.quoteOfTheDay(for: Date())
    }

    func signIn(using method: AuthMethod) {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        authService.signIn(using: method) { [weak self] result in
            guard let self else { return }
            self.isProcessing = false
            switch result {
            case .success(let session):
                self.session = session
                self.appFlow = self.userProfile == nil ? .profileSetup : .main
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func register(email: String, password: String) {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil

        authService.register(email: email, password: password) { [weak self] result in
            guard let self else { return }
            self.isProcessing = false

            switch result {
            case .success(let session):
                self.session = session
                self.appFlow = .profileSetup
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func startAppleSignIn() {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let coordinator = AppleSignInCoordinator { [weak self] result in
            guard let self else { return }
            self.appleSignInCoordinator = nil
            switch result {
            case .success(let session):
                self.session = session
                self.appFlow = self.userProfile == nil ? .profileSetup : .main
                self.isProcessing = false
            case .failure(let error):
                self.isProcessing = false
                if error != .cancelled {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        controller.delegate = coordinator
        controller.presentationContextProvider = coordinator
        appleSignInCoordinator = coordinator
        controller.performRequests()
    }

    func completeProfile(_ profile: UserProfile) {
        userProfile = profile
        if session == nil {
            session = AuthSession(id: UUID(), displayName: profile.name)
        }
        appFlow = .main
    }

    func updateProfile(_ profile: UserProfile) {
        userProfile = profile
    }

    func generateSoulmateVisual() {
        guard let profile = userProfile else { return }
        isProcessing = true
        soulmateService.generateSoulmateVisual(for: profile) { [weak self] result in
            guard let self else { return }
            self.isProcessing = false
            switch result {
            case .success(let visual):
                self.currentVisual = visual
                self.soulmateHistory.insert(visual, at: 0)
            case .failure:
                self.errorMessage = "Görsel oluşturulamadı. Daha sonra tekrar deneyin."
            }
        }
    }

    func evaluateSoulmate(with candidate: CandidateProfile) {
        guard let profile = userProfile else { return }
        isProcessing = true
        soulmateService.evaluateMatch(between: profile, and: candidate) { [weak self] result in
            guard let self else { return }
            self.isProcessing = false
            switch result {
            case .success(let match):
                self.currentMatchResult = match
            case .failure:
                self.errorMessage = "Uyumluluk hesaplanamadı."
            }
        }
    }

    func resetMatchResult() {
        currentMatchResult = nil
    }

    func logout() {
        authService.logout()
        appFlow = .onboarding
        session = nil
        userProfile = nil
        soulmateHistory = []
        currentVisual = nil
        currentMatchResult = nil
    }
}

private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let completion: (Result<AuthSession, AuthError>) -> Void

    init(completion: @escaping (Result<AuthSession, AuthError>) -> Void) {
        self.completion = completion
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return ASPresentationAnchor()
        }
        return window
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion(.failure(.generic))
            return
        }

        let displayNameComponents = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let resolvedName: String
        if !displayNameComponents.isEmpty {
            resolvedName = displayNameComponents.joined(separator: " ")
        } else if let emailHandle = credential.email?.split(separator: "@").first {
            resolvedName = String(emailHandle)
        } else {
            resolvedName = "Apple Kullanıcısı"
        }

        let session = AuthSession(id: UUID(), displayName: resolvedName)
        completion(.success(session))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain,
           nsError.code == ASAuthorizationError.canceled.rawValue {
            completion(.failure(.cancelled))
        } else {
            completion(.failure(.generic))
        }
    }
}
