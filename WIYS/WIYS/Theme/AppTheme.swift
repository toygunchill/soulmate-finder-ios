import SwiftUI

enum AppColors {
    static let indigo = Color(hex: "#4E56C0")
    static let violet = Color(hex: "#9B5DE0")
    static let orchid = Color(hex: "#D78FEE")
    static let blush = Color(hex: "#FDCFFA")

    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let surface = Color.white.opacity(0.92)
}

enum AppGradients {
    static let onboardingBackground = LinearGradient(
        colors: [AppColors.indigo, AppColors.violet.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [AppColors.violet, AppColors.orchid],
        startPoint: .leading,
        endPoint: .trailing
    )
}
