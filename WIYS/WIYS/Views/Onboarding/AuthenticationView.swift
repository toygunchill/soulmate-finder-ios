import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showEmailSheet = false
    @State private var showRegisterSheet = false

    var body: some View {
        ZStack {
            AppGradients.onboardingBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("WIYS")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    Text("Who Is Your Soulmate?")
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.9))
                    Text("Ruh eşinin izini sür, enerjini paylaş, hikâyeni dünyayla kutla.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 14) {
                    AuthButton(title: "Apple ile devam et", systemImage: "apple.logo", style: .solid) {
                        appViewModel.startAppleSignIn()
                    }
                    AuthButton(title: "E-posta ile giriş yap", systemImage: "envelope", style: .tonal) {
                        showEmailSheet = true
                        showRegisterSheet = false
                    }
                    AuthButton(title: "E-posta ile kayıt ol", systemImage: "person.badge.plus", style: .tonal) {
                        showRegisterSheet = true
                        showEmailSheet = false
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
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showEmailSheet) {
            EmailLoginSheet { email, password in
                appViewModel.signIn(using: .email(email: email, password: password))
            }
            .presentationDetents([.fraction(0.5)])
        }
        .sheet(isPresented: $showRegisterSheet) {
            EmailRegisterSheet { email, password in
                appViewModel.register(email: email, password: password)
            }
            .presentationDetents([.fraction(0.6)])
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

struct EmailRegisterSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    let onSubmit: (String, String) -> Void

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password == confirmPassword
    }

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
                    SecureField("Şifreyi tekrar girin", text: $confirmPassword)
                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Şifreler eşleşmiyor")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Kayıt ol")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Devam") {
                        dismiss()
                        onSubmit(email, password)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}
