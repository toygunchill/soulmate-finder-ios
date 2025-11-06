import SwiftUI

struct SoulmateVisualDetail: View {
    let visual: SoulmateVisual

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(visual.gradient)
                .frame(height: 340)
                .overlay(alignment: .center) {
                    VStack(spacing: 10) {
                        Image(systemName: visual.palette.iconName)
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text(visual.palette.mood.capitalized)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .shadow(radius: 10)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("AI vizyonu")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(AppColors.indigo)
                Text(visual.description)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(AppColors.indigo.opacity(0.75))
                Text(visual.formattedDate)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppColors.indigo.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppColors.blush.opacity(0.25), lineWidth: 1)
            )
        }
    }
}
