import Foundation

protocol AuthService {
    func signIn(using method: AuthMethod, completion: @escaping (Result<AuthSession, AuthError>) -> Void)
    func register(email: String, password: String, completion: @escaping (Result<AuthSession, AuthError>) -> Void)
    func logout()
}

protocol SoulmateService {
    func generateSoulmateVisual(for profile: UserProfile, completion: @escaping (Result<SoulmateVisual, Error>) -> Void)
    func evaluateMatch(between profile: UserProfile, and candidate: CandidateProfile, completion: @escaping (Result<SoulmateMatchResult, Error>) -> Void)
    func quoteOfTheDay(for date: Date) -> SoulmateQuote
}

final class MockAuthService: AuthService {
    private var activeSession: AuthSession?

    func signIn(using method: AuthMethod, completion: @escaping (Result<AuthSession, AuthError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            switch method {
            case .email(let email, let password):
                guard !email.isEmpty, !password.isEmpty else {
                    completion(.failure(.invalidCredentials))
                    return
                }
                let session = AuthSession(id: UUID(), displayName: email.components(separatedBy: "@").first ?? "Sen")
                self.activeSession = session
                completion(.success(session))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<AuthSession, AuthError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard !email.isEmpty, !password.isEmpty else {
                completion(.failure(.invalidCredentials))
                return
            }

            let session = AuthSession(id: UUID(), displayName: email.components(separatedBy: "@").first ?? "Sen")
            self.activeSession = session
            completion(.success(session))
        }
    }

    func logout() {
        activeSession = nil
    }
}

final class MockSoulmateService: SoulmateService {
    private let palettes: [SoulmateVisualPalette] = [
        SoulmateVisualPalette(
            colorStops: [PaletteColor(hex: "#4E56C0"), PaletteColor(hex: "#9B5DE0"), PaletteColor(hex: "#D78FEE")],
            iconName: "sparkles",
            mood: "lunar glow"
        ),
        SoulmateVisualPalette(
            colorStops: [PaletteColor(hex: "#4E56C0"), PaletteColor(hex: "#D78FEE"), PaletteColor(hex: "#FDCFFA")],
            iconName: "moon.stars",
            mood: "starlit daydream"
        ),
        SoulmateVisualPalette(
            colorStops: [PaletteColor(hex: "#9B5DE0"), PaletteColor(hex: "#D78FEE"), PaletteColor(hex: "#FDCFFA")],
            iconName: "heart.circle",
            mood: "violet heartbeat"
        ),
        SoulmateVisualPalette(
            colorStops: [PaletteColor(hex: "#4E56C0"), PaletteColor(hex: "#9B5DE0", opacity: 0.85), PaletteColor(hex: "#FDCFFA", opacity: 0.9)],
            iconName: "cloud.sun.rain",
            mood: "soft horizon"
        )
    ]

    private let quotes: [SoulmateQuote] = [
        SoulmateQuote(text: "Your soulmate might be closer than you think 💫", author: "WIYS"),
        SoulmateQuote(text: "Two energies orbiting the same dream.", author: "Astral Journal"),
        SoulmateQuote(text: "Love is a frequency – tune in daily.", author: "Celestial Notes"),
        SoulmateQuote(text: "Some connections bend time itself.", author: "Stellar Whisper")
    ]

    func generateSoulmateVisual(for profile: UserProfile, completion: @escaping (Result<SoulmateVisual, Error>) -> Void) {
        let palette = palettes.randomElement() ?? palettes[0]
        let hobbySnippet = profile.hobbies.randomElement() ?? "paylaştığınız tutkular"
        let description = "\(profile.name) için \(palette.mood) dokusunda, \(hobbySnippet.lowercased()) vurgulu bir ruh eşi portresi."

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            completion(.success(SoulmateVisual(description: description, palette: palette)))
        }
    }

    func evaluateMatch(between profile: UserProfile, and candidate: CandidateProfile, completion: @escaping (Result<SoulmateMatchResult, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let baseScore = Int.random(in: 55...98)
            let shared = Set(profile.hobbies.map { $0.lowercased() }).intersection(candidate.hobbies.map { $0.lowercased() })
            let finalScore = min(99, baseScore + shared.count * 3)
            let summary = "\(candidate.name) ile enerjiniz %\(finalScore) uyumlu görünüyor! Ortak titreşimler: \(shared.isEmpty ? "keşfedilmeyi bekliyor" : shared.joined(separator: ", "))."
            completion(.success(SoulmateMatchResult(compatibilityScore: finalScore, summary: summary, sharedKeywords: Array(shared))))
        }
    }

    func quoteOfTheDay(for date: Date) -> SoulmateQuote {
        let index = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        return quotes[index % quotes.count]
    }
}
