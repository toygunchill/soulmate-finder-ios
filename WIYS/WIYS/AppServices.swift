import Foundation

protocol AuthService {
    func signIn(using method: AuthMethod, completion: @escaping (Result<AuthSession, AuthError>) -> Void)
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
            let session: AuthSession
            switch method {
            case .apple:
                session = AuthSession(id: UUID(), displayName: "Apple User")
            case .google:
                session = AuthSession(id: UUID(), displayName: "Google Explorer")
            case .email(let email, let password):
                guard !email.isEmpty, !password.isEmpty else {
                    completion(.failure(.invalidCredentials))
                    return
                }
                session = AuthSession(id: UUID(), displayName: email.components(separatedBy: "@").first ?? "Sen")
            }
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
            colorStops: [PaletteColor(hex: "#FF9A9E"), PaletteColor(hex: "#FAD0C4"), PaletteColor(hex: "#FBC2EB")],
            iconName: "sparkles",
            mood: "romantic aurora"
        ),
        SoulmateVisualPalette(
            colorStops: [PaletteColor(hex: "#A18CD1"), PaletteColor(hex: "#FBC2EB"), PaletteColor(hex: "#8EC5FC")],
            iconName: "moon.stars",
            mood: "dreamy twilight"
        ),
        SoulmateVisualPalette(
            colorStops: [PaletteColor(hex: "#6A85B6"), PaletteColor(hex: "#BAC8E0"), PaletteColor(hex: "#F6D6FF")],
            iconName: "cloud.sun.rain",
            mood: "soft serenity"
        ),
        SoulmateVisualPalette(
            colorStops: [PaletteColor(hex: "#F5E6CA"), PaletteColor(hex: "#F28FAD"), PaletteColor(hex: "#9B5DE5")],
            iconName: "heart.circle",
            mood: "cosmic heartbeat"
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
