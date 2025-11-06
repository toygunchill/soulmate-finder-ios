import SwiftUI

struct SoulmateVisualizerView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let visual = appViewModel.currentVisual ?? appViewModel.soulmateHistory.first {
                SoulmateVisualDetail(visual: visual)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    ShareLink(item: visualShareText(visual)) {
                        Label("Paylaş", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        appViewModel.generateSoulmateVisual()
                    } label: {
                        Label("Tekrar oluştur", systemImage: "goforward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .tint(AppColors.violet)
                .padding(.horizontal)
            } else {
                PlaceholderVisualizer()
                    .padding()
            }

            Spacer()
        }
        .padding(.top)
        .background(AppColors.secondaryBackground)
        .navigationTitle("Soulmate Görseli")
        .onAppear {
            if appViewModel.currentVisual == nil && appViewModel.soulmateHistory.isEmpty {
                appViewModel.generateSoulmateVisual()
            }
        }
        .overlay(alignment: .top) {
            if appViewModel.isProcessing {
                ProgressView("AI çalışıyor...")
                    .padding()
                    .background(AppColors.surface)
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }

    private func visualShareText(_ visual: SoulmateVisual) -> String {
        "WIYS ile oluşturuldu: \(visual.description)"
    }
}

struct PlaceholderVisualizer: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(AppColors.violet)
            Text("Ruh eşinin portresi hazırlanıyor...")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(AppColors.indigo.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}
