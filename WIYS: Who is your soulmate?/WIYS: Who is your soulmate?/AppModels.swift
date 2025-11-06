import Foundation
import SwiftUI

struct UserProfile: Equatable {
    var name: String
    var birthDate: Date
    var occupation: String
    var hobbies: [String]
}

struct CandidateProfile: Equatable {
    var name: String
    var birthDate: Date
    var occupation: String
    var hobbies: [String]
}

struct SoulmateVisualPalette: Hashable {
    var colorStops: [PaletteColor]
    var iconName: String
    var mood: String
}

struct PaletteColor: Hashable {
    var hex: String
    var opacity: Double = 1.0

    var color: Color {
        Color(hex: hex).opacity(opacity)
    }
}

struct SoulmateVisual: Identifiable, Equatable {
    let id: UUID
    let createdAt: Date
    let description: String
    let palette: SoulmateVisualPalette

    init(id: UUID = UUID(), createdAt: Date = Date(), description: String, palette: SoulmateVisualPalette) {
        self.id = id
        self.createdAt = createdAt
        self.description = description
        self.palette = palette
    }
}

struct SoulmateMatchResult: Identifiable, Equatable {
    let id: UUID
    let compatibilityScore: Int
    let summary: String
    let sharedKeywords: [String]

    init(id: UUID = UUID(), compatibilityScore: Int, summary: String, sharedKeywords: [String]) {
        self.id = id
        self.compatibilityScore = compatibilityScore
        self.summary = summary
        self.sharedKeywords = sharedKeywords
    }
}

enum AuthMethod {
    case apple
    case google
    case email(email: String, password: String)
}

enum AppFlow {
    case onboarding
    case profileSetup
    case main
}

struct AuthSession: Equatable {
    let id: UUID
    let displayName: String
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case cancelled
    case generic

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "E-posta veya şifreyi kontrol edin."
        case .cancelled:
            return "Giriş işlemi iptal edildi."
        case .generic:
            return "Beklenmedik bir hata oluştu. Tekrar deneyin."
        }
    }
}

struct SoulmateQuote: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let author: String
}

extension SoulmateVisual {
    var gradient: LinearGradient {
        let colors = palette.colorStops.map { $0.color }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

extension SoulmateMatchResult {
    var headline: String {
        "Uyumluluk: %\(compatibilityScore)"
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        let r, g, b, a: Double
        switch sanitized.count {
        case 3: // RGB 12-bit
            r = Double((value & 0xF00) >> 8) / 15
            g = Double((value & 0x0F0) >> 4) / 15
            b = Double(value & 0x00F) / 15
            a = 1.0
        case 6: // RGB 24-bit
            r = Double((value & 0xFF0000) >> 16) / 255
            g = Double((value & 0x00FF00) >> 8) / 255
            b = Double(value & 0x0000FF) / 255
            a = 1.0
        case 8: // ARGB 32-bit
            a = Double((value & 0xFF000000) >> 24) / 255
            r = Double((value & 0x00FF0000) >> 16) / 255
            g = Double((value & 0x0000FF00) >> 8) / 255
            b = Double(value & 0x000000FF) / 255
        default:
            r = 0.5
            g = 0.5
            b = 0.5
            a = 1.0
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension UserProfile {
    static var sample: UserProfile {
        UserProfile(
            name: "Luna",
            birthDate: Calendar.current.date(from: DateComponents(year: 1994, month: 4, day: 16)) ?? .now,
            occupation: "Product Designer",
            hobbies: ["Yoga", "Photography", "Synthwave"]
        )
    }
}
