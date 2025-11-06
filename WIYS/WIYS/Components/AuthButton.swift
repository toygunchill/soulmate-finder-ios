import SwiftUI

struct AuthButton: View {
    enum Style {
        case solid
        case tonal
    }

    let title: String
    let systemImage: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(.headline, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: style == .solid ? 0 : 1.5)
            )
        }
    }

    private var background: some ShapeStyle {
        switch style {
        case .solid:
            return AnyShapeStyle(Color.white)
        case .tonal:
            return AnyShapeStyle(AppColors.surface)
        }
    }

    private var foreground: some ShapeStyle {
        switch style {
        case .solid:
            return AnyShapeStyle(Color.black)
        case .tonal:
            return AnyShapeStyle(AppColors.indigo)
        }
    }

    private var borderColor: Color {
        switch style {
        case .solid:
            return .clear
        case .tonal:
            return AppColors.indigo.opacity(0.35)
        }
    }
}
