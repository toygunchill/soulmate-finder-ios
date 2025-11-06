import SwiftUI
import UIKit

struct SoulmateMatchView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var candidate = CandidateProfile(name: "", birthDate: Date(), occupation: "", hobbies: [])
    @State private var hobbiesText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enerji eşleşmesini test et")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.indigo)
                    Text("Adayının bilgilerini paylaş, yapay zekâ uyumunuzu analiz etsin.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(AppColors.indigo.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                .padding(.horizontal)

                VStack(spacing: 20) {
                    InputCard(title: "Adı") {
                        TextField("Adayın adı", text: Binding(
                            get: { candidate.name },
                            set: { candidate.name = $0 }
                        ))
                        .textInputAutocapitalization(.words)
                    }

                    InputCard(title: "Doğum tarihi") {
                        DatePicker("", selection: Binding(
                            get: { candidate.birthDate },
                            set: { candidate.birthDate = $0 }
                        ), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                    }

                    InputCard(title: "Mesleği") {
                        TextField("Ne işle meşgul?", text: Binding(
                            get: { candidate.occupation },
                            set: { candidate.occupation = $0 }
                        ))
                        .textInputAutocapitalization(.words)
                    }

                    InputCard(title: "Hobileri") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Virgülle ayırarak yaz (ör. yoga, kamp, sinema)", text: $hobbiesText)
                                .textInputAutocapitalization(.never)
                            Text("\(candidate.hobbies.count) hobi eklendi")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppColors.indigo.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal)

                PrimaryButton(title: "Uyumluluğu hesapla") {
                    let hobbies = hobbiesText
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    candidate.hobbies = hobbies
                    appViewModel.evaluateMatch(with: candidate)
                }
                .padding(.horizontal)

                if let match = appViewModel.latestMatch {
                    MatchResultCard(match: match)
                        .padding(.horizontal)
                }

                Spacer(minLength: 32)
            }
        }
        .background(AppColors.secondaryBackground)
        .navigationTitle("Uyumluluk")
    }
}

struct MatchResultCard: View {
    let match: SoulmateMatchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Uyumluluk skoru")
                        .font(.system(.callout, design: .rounded).weight(.medium))
                        .foregroundStyle(AppColors.indigo.opacity(0.7))
                    Text("%\(match.compatibilityScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.violet)
                }
                Spacer()
            }

            Text(match.summary)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(AppColors.indigo)

            if !match.sharedKeywords.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ortak titreşimler")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(AppColors.indigo.opacity(0.7))
                    FlowTags(items: match.sharedKeywords)
                }
            }

            ShareLink(item: "WIYS sonucu: \(match.summary)") {
                Label("Sonucu paylaş", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.violet)
        }
        .padding()
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: AppColors.indigo.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}

struct FlowTags: View {
    let items: [String]

    var body: some View {
        FlexibleView(data: items, spacing: 8, alignment: .leading) { item in
            Text(item.capitalized)
                .font(.system(.footnote, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.blush.opacity(0.45))
                .clipShape(Capsule())
        }
    }
}

struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(Array(generateRows().enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self, content: content)
                }
            }
        }
    }

    private func generateRows() -> [[Data.Element]] {
        guard !data.isEmpty else { return [] }
        var rows: [[Data.Element]] = [[]]
        var currentWidth: CGFloat = 0
        let maxWidth = UIScreen.main.bounds.width - 48

        for element in data {
            let elementWidth = elementWidth(for: element)

            if currentWidth + elementWidth > maxWidth {
                rows.append([element])
                currentWidth = elementWidth + spacing
            } else {
                rows[rows.count - 1].append(element)
                currentWidth += elementWidth + spacing
            }
        }

        return rows.filter { !$0.isEmpty }
    }

    private func elementWidth(for element: Data.Element) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (String(describing: element) as NSString).size(withAttributes: attributes)
        return size.width + 24
    }
}
