import SwiftUI

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
                            .foregroundStyle(AppColors.indigo)
                            .multilineTextAlignment(.center)
                        Text("Ruh eşini daha iyi tanımlayabilmemiz için birkaç bilgi.")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(AppColors.indigo.opacity(0.7))
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

                                HStack(spacing: 12) {
                                    TextField("Yeni hobi ekle", text: $customHobby)
                                        .textInputAutocapitalization(.sentences)
                                    Button {
                                        addCustomHobby()
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(AppColors.violet)
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
                    .opacity(isFormValid ? 1 : 0.6)

                    if !appViewModel.quoteOfTheDay.text.isEmpty {
                        DailyQuoteCard(quote: appViewModel.quoteOfTheDay)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 24)
                }
            }
            .background(AppColors.secondaryBackground)
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
