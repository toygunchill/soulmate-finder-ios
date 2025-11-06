import SwiftUI

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
                                .foregroundStyle(AppColors.indigo)
                            Text(profile.occupation)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(AppColors.indigo.opacity(0.7))
                            Text(profile.birthDate, style: .date)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(AppColors.indigo.opacity(0.6))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(AppColors.blush.opacity(0.25), lineWidth: 1)
                        )
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
                                .foregroundStyle(AppColors.indigo.opacity(0.75))
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
                                .foregroundStyle(AppColors.violet)
                            Text("Henüz bir görsel oluşturmadın")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(AppColors.indigo)
                            Text("Ana sayfadan ruh eşinin portresini keşfetmeye başla.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(AppColors.indigo.opacity(0.7))
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
                    .tint(AppColors.indigo)
                    .padding(.horizontal)

                    Spacer(minLength: 48)
                }
            }
            .background(AppColors.secondaryBackground)
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
