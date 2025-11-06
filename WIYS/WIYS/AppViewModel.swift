import Foundation
import SwiftUI

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
