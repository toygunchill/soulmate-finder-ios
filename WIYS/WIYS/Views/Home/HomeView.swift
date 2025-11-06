import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var navigateToVisualizer = false
    @State private var navigateToMatcher = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    DailyQuoteCard(quote: appViewModel.quoteOfTheDay)
                        .padding(.top, 24)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        HomeActionCard(
                            title: "Soulmate'im neye benziyor?",
                            subtitle: "Profil bilgilerine göre AI görseli oluştur.",
                            icon: "wand.and.stars",
                            gradient: LinearGradient(colors: [AppColors.violet, AppColors.orchid], startPoint: .topLeading, endPoint: .bottomTrailing)
                        ) {
                            navigateToVisualizer = true
                        }

                        HomeActionCard(
                            title: "Bu kişi benim soulmate'im mi?",
                            subtitle: "Uyumluluk analizini keşfet.",
                            icon: "heart.text.square",
                            gradient: LinearGradient(colors: [AppColors.indigo, AppColors.violet], startPoint: .topLeading, endPoint: .bottomTrailing)
                        ) {
                            navigateToMatcher = true
                        }
                    }
                    .padding(.horizontal)

                    if !appViewModel.soulmateHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Son oluşturdukların")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(AppColors.indigo.opacity(0.75))
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(appViewModel.soulmateHistory.prefix(5)) { visual in
                                        SoulmatePreviewCard(visual: visual)
                                            .frame(width: 200, height: 240)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 32)
                }
            }
            .background(AppColors.secondaryBackground)
            .navigationDestination(isPresented: $navigateToVisualizer) {
                SoulmateVisualizerView()
            }
            .navigationDestination(isPresented: $navigateToMatcher) {
                SoulmateMatchView()
            }
            .navigationTitle("WIYS")
        }
    }
}

struct HomeActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: AppColors.indigo.opacity(0.25), radius: 12, x: 0, y: 8)
        }
    }
}

struct SoulmatePreviewCard: View {
    let visual: SoulmateVisual

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(visual.gradient)
                .frame(height: 160)
                .overlay(
                    Image(systemName: visual.palette.iconName)
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.9))
                )

            Text(visual.palette.mood.capitalized)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(AppColors.indigo)
            Text(visual.description)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(AppColors.indigo.opacity(0.7))
                .lineLimit(2)
        }
        .padding()
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.blush.opacity(0.25), lineWidth: 1)
        )
    }
}
