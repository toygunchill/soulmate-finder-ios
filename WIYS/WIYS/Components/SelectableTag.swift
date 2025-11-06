import SwiftUI

struct SelectableTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
                .background(background)
                .foregroundStyle(foreground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColors.violet.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
    }

    private var background: Color {
        isSelected ? AppColors.violet : AppColors.surface
    }

    private var foreground: Color {
        isSelected ? .white : AppColors.indigo
    }
}
