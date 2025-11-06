import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            switch appViewModel.appFlow {
            case .onboarding:
                AuthenticationView()
            case .profileSetup:
                ProfileSetupView()
            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut, value: appViewModel.appFlow)
        .alert("Bir şeyler ters gitti", isPresented: .constant(appViewModel.errorMessage != nil), actions: {
            Button("Tamam", role: .cancel) {
                appViewModel.errorMessage = nil
            }
        }, message: {
            Text(appViewModel.errorMessage ?? "")
        })
    }
}

// MARK: - Authentication

struct AuthenticationView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showEmailSheet = false

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#221D41"), Color(hex: "#513173"), Color(hex: "#F28FAD")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("WIYS")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                    Text("Who Is Your Soulmate?")
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                    Text("Ruh eşinin izini sür, enerjini paylaş, hikâyeni dünyayla kutla.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 14) {
                    AuthButton(title: "Apple ile devam et", systemImage: "apple.logo", style: .solidWhite) {
                        appViewModel.startAppleSignIn()
                    }
                    AuthButton(title: "E-posta ile giriş yap", systemImage: "envelope", style: .translucent) {
                        showEmailSheet = true
                    }
                }
                .padding(.horizontal)

                if appViewModel.isProcessing {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 8)
                }

                Spacer()

                Text("Giriş yaparak ruh eşini keşfetme yolculuğunu başlatırsın ✨")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showEmailSheet) {
            EmailLoginSheet { email, password in
                appViewModel.signIn(using: .email(email: email, password: password))
            }
            .presentationDetents([.fraction(0.5)])
            .background(Color(.systemBackground))
        }
    }
}

struct EmailLoginSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""

    let onSubmit: (String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("E-posta")) {
                    TextField("ornek@mail.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section(header: Text("Şifre")) {
                    SecureField("••••••••", text: $password)
                }
            }
            .navigationTitle("E-posta ile giriş")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Devam") {
                        dismiss()
                        onSubmit(email, password)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                }
            }
        }
    }
}

struct AuthButton: View {
    enum Style {
        case solidWhite
        case translucent
    }

    let title: String
    let systemImage: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(.headline, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding()
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(borderColor, lineWidth: style == .solidWhite ? 0 : 1.5)
            )
        }
    }

    private var background: some ShapeStyle {
        switch style {
        case .solidWhite:
            return AnyShapeStyle(Color.white)
        case .translucent:
            return AnyShapeStyle(Color.white.opacity(0.08))
        }
    }

    private var foreground: some ShapeStyle {
        switch style {
        case .solidWhite:
            return AnyShapeStyle(Color.black)
        default:
            return AnyShapeStyle(Color.white)
        }
    }

    private var borderColor: Color {
        switch style {
        case .solidWhite:
            return .clear
        case .translucent:
            return .white.opacity(0.6)
        }
    }
}

// MARK: - Profile Setup

struct ProfileSetupView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    @State private var name: String = ""
    @State private var birthDate: Date = Calendar.current.date(from: DateComponents(year: 1996, month: 2, day: 14)) ?? .now
    @State private var occupation: String = ""
    @State private var selectedHobbies: Set<String> = []
    @State private var customHobby: String = ""

    private let suggestedHobbies = [
        "Yoga", "Astroloji", "Dans", "Seyahat", "Fotoğrafçılık",
        "Müzik yapma", "Kitap Kulübü", "Meditasyon", "Koşu", "Gastronomi"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        Text("Profilini parlat ✨")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .foregroundStyle(LinearGradient(colors: [Color(hex: "#F28FAD"), Color(hex: "#8EC5FC")], startPoint: .leading, endPoint: .trailing))
                            .multilineTextAlignment(.center)
                        Text("Ruh eşini daha iyi tanımlayabilmemiz için birkaç bilgi.")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 20) {
                        InputCard(title: "Adın") {
                            TextField("Adın", text: $name)
                                .textInputAutocapitalization(.words)
                        }

                        InputCard(title: "Doğum Tarihin") {
                            DatePicker("", selection: $birthDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                        }

                        InputCard(title: "Mesleğin") {
                            TextField("Ne iş yapıyorsun?", text: $occupation)
                                .textInputAutocapitalization(.words)
                        }

                        InputCard(title: "Hobilerin") {
                            VStack(alignment: .leading, spacing: 12) {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 12)], spacing: 12) {
                                    ForEach(suggestedHobbies, id: \.self) { hobby in
                                        SelectableTag(title: hobby, isSelected: selectedHobbies.contains(hobby)) {
                                            toggleHobby(hobby)
                                        }
                                    }
                                }

                                HStack {
                                    TextField("Yeni hobi ekle", text: $customHobby)
                                        .textInputAutocapitalization(.sentences)
                                    Button {
                                        addCustomHobby()
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                    .disabled(customHobby.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    PrimaryButton(title: "Devam et") {
                        let profile = UserProfile(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            birthDate: birthDate,
                            occupation: occupation.trimmingCharacters(in: .whitespacesAndNewlines),
                            hobbies: Array(selectedHobbies).sorted()
                        )
                        appViewModel.completeProfile(profile)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal)

                    if !appViewModel.quoteOfTheDay.text.isEmpty {
                        DailyQuoteCard(quote: appViewModel.quoteOfTheDay)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 24)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profilini oluştur")
        }
        .onAppear(perform: populateForm)
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !occupation.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedHobbies.isEmpty
    }

    private func populateForm() {
        if let profile = appViewModel.userProfile {
            name = profile.name
            birthDate = profile.birthDate
            occupation = profile.occupation
            selectedHobbies = Set(profile.hobbies)
        }
    }

    private func toggleHobby(_ hobby: String) {
        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else {
            selectedHobbies.insert(hobby)
        }
    }

    private func addCustomHobby() {
        let trimmed = customHobby.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        selectedHobbies.insert(trimmed)
        customHobby = ""
    }
}

struct InputCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.headline, design: .rounded))
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct SelectableTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
            }
            .frame(maxWidth: .infinity)
            .background(isSelected ? LinearGradient(colors: [Color(hex: "#F28FAD"), Color(hex: "#8EC5FC")], startPoint: .leading, endPoint: .trailing) : Color(.systemBackground))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.35), lineWidth: 1)
            )
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [Color(hex: "#F28FAD"), Color(hex: "#A18CD1")], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color(hex: "#F28FAD").opacity(0.4), radius: 10, x: 0, y: 6)
        }
    }
}

// MARK: - Main Tab

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "sparkles")
                }
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle")
                }
        }
    }
}

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
                            gradient: [Color(hex: "#F28FAD"), Color(hex: "#A18CD1")]
                        ) {
                            navigateToVisualizer = true
                        }

                        HomeActionCard(
                            title: "Bu kişi benim soulmate'im mi?",
                            subtitle: "Uyumluluk analizini keşfet.",
                            icon: "heart.text.square",
                            gradient: [Color(hex: "#8EC5FC"), Color(hex: "#C3A3F1")]
                        ) {
                            navigateToMatcher = true
                        }
                    }
                    .padding(.horizontal)

                    if !appViewModel.soulmateHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Son oluşturdukların")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.secondary)

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
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 32)
                }
            }
            .background(LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom))
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
    let gradient: [Color]
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
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: gradient.first?.opacity(0.35) ?? .black.opacity(0.3), radius: 12, x: 0, y: 8)
        }
    }
}

struct SoulmatePreviewCard: View {
    let visual: SoulmateVisual

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(visual.gradient)
                .overlay(
                    Image(systemName: visual.palette.iconName)
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.9))
                )
                .frame(height: 160)
            Text(visual.palette.mood.capitalized)
                .font(.system(.headline, design: .rounded))
            Text(visual.description)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - Soulmate Visualizer

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
                .tint(Color(hex: "#A18CD1"))
                .padding(.horizontal)
            } else {
                PlaceholderVisualizer()
                    .padding()
            }

            Spacer()
        }
        .padding(.top)
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
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }

    private func visualShareText(_ visual: SoulmateVisual) -> String {
        "WIYS ile oluşturuldu: \(visual.description)"
    }
}

struct SoulmateVisualDetail: View {
    let visual: SoulmateVisual

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(visual.gradient)
                .frame(height: 360)
                .overlay(alignment: .center) {
                    VStack(spacing: 12) {
                        Image(systemName: visual.palette.iconName)
                            .font(.system(size: 54, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.95))
                        Text(visual.palette.mood.capitalized)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .shadow(radius: 12)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("AI vizyonu")
                    .font(.system(.headline, design: .rounded))
                Text(visual.description)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(visual.formattedDate)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }
}

struct PlaceholderVisualizer: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color(hex: "#A18CD1"))
            Text("Ruh eşinin portresi hazırlanıyor...")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Soulmate Match

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
                    Text("Adayının bilgilerini paylaş, yapay zekâ uyumunuzu analiz etsin.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)

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
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                PrimaryButton(title: "Uyumluluğu hesapla") {
                    candidate.hobbies = hobbiesText
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    appViewModel.evaluateSoulmate(with: candidate)
                }
                .padding(.horizontal)
                .disabled(!formValid)

                if let match = appViewModel.currentMatchResult {
                    MatchResultCard(match: match)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: match)
                }

                Spacer(minLength: 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Soulmate Analizi")
        .toolbar {
            if appViewModel.currentMatchResult != nil {
                Button("Sıfırla") {
                    appViewModel.resetMatchResult()
                }
            }
        }
        .overlay(alignment: .top) {
            if appViewModel.isProcessing {
                ProgressView("Enerjiler karşılaştırılıyor...")
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }

    private var formValid: Bool {
        !candidate.name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !candidate.occupation.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

struct MatchResultCard: View {
    let match: SoulmateMatchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "#F28FAD"), Color(hex: "#C779D0")], startPoint: .top, endPoint: .bottom))
                VStack(alignment: .leading) {
                    Text(match.headline)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                    Text(match.summary)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            if !match.sharedKeywords.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ortak titreşimler")
                        .font(.system(.headline, design: .rounded))
                    FlowTags(items: match.sharedKeywords)
                }
            }

            ShareLink(item: "WIYS sonucu: \(match.summary)") {
                Label("Sonucu paylaş", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#A18CD1"))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
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
                .background(Color(hex: "#FAD0C4").opacity(0.4))
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

// MARK: - Profile

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isEditing = false
    @State private var name: String = ""
    @State private var occupation: String = ""
    @State private var hobbies: String = ""
    @State private var birthDate: Date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let profile = appViewModel.userProfile {
                        VStack(spacing: 12) {
                            Text(profile.name)
                                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            Text(profile.occupation)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(profile.birthDate, style: .date)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding(.horizontal)
                    }

                    if isEditing {
                        VStack(spacing: 16) {
                            InputCard(title: "Adın") {
                                TextField("Adın", text: $name)
                            }
                            InputCard(title: "Mesleğin") {
                                TextField("Mesleğin", text: $occupation)
                            }
                            InputCard(title: "Doğum tarihin") {
                                DatePicker("", selection: $birthDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                            InputCard(title: "Hobilerin") {
                                TextField("Virgülle ayır", text: $hobbies)
                            }

                            PrimaryButton(title: "Profili kaydet") {
                                let updated = UserProfile(
                                    name: name,
                                    birthDate: birthDate,
                                    occupation: occupation,
                                    hobbies: hobbies.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                                )
                                appViewModel.updateProfile(updated)
                                withAnimation {
                                    isEditing = false
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !appViewModel.soulmateHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Soulmate görsel geçmişin")
                                .font(.system(.headline, design: .rounded))
                                .padding(.horizontal)
                            LazyVStack(spacing: 16) {
                                ForEach(appViewModel.soulmateHistory) { visual in
                                    SoulmateVisualDetail(visual: visual)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundStyle(Color(hex: "#A18CD1"))
                            Text("Henüz bir görsel oluşturmadın")
                                .font(.system(.headline, design: .rounded))
                            Text("Ana sayfadan ruh eşinin portresini keşfetmeye başla.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }

                    Button(role: .destructive) {
                        appViewModel.logout()
                    } label: {
                        Text("Çıkış yap")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)

                    Spacer(minLength: 48)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profilim")
            .toolbar {
                Button(isEditing ? "Vazgeç" : "Düzenle") {
                    if isEditing {
                        withAnimation {
                            isEditing = false
                        }
                        populateFields()
                    } else {
                        populateFields()
                        withAnimation {
                            isEditing = true
                        }
                    }
                }
            }
        }
    }

    private func populateFields() {
        guard let profile = appViewModel.userProfile else { return }
        name = profile.name
        occupation = profile.occupation
        birthDate = profile.birthDate
        hobbies = profile.hobbies.joined(separator: ", ")
    }
}

// MARK: - Shared UI

struct DailyQuoteCard: View {
    let quote: SoulmateQuote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkle")
                    .font(.system(size: 28))
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "#FAD0C4"), Color(hex: "#F28FAD")], startPoint: .top, endPoint: .bottom))
                Spacer()
                Text("Günün Sözü")
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text("\"\(quote.text)\"")
                .font(.system(.title3, design: .rounded).weight(.medium))
            Text("— \(quote.author)")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel(authService: MockAuthService(), soulmateService: MockSoulmateService()))
}
