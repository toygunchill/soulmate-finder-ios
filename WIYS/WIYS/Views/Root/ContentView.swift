import SwiftUI

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

#Preview {
    ContentView()
        .environmentObject(AppViewModel(authService: MockAuthService(), soulmateService: MockSoulmateService()))
}
