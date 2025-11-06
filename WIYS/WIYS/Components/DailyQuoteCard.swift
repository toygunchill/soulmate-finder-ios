import SwiftUI

struct DailyQuoteCard: View {
    let quote: SoulmateQuote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkle")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.orchid)
                Spacer()
                Text("Günün Sözü")
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppColors.indigo.opacity(0.7))
            }

            Text("\"\(quote.text)\"")
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundStyle(AppColors.indigo)

            Text("— \(quote.author)")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(AppColors.indigo.opacity(0.6))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.blush.opacity(0.4), lineWidth: 1)
        )
    }
}
