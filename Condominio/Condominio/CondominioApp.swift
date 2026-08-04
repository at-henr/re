import SwiftUI

@main
struct ItapoaApp: App {
    @StateObject var db = DatabaseManager()
    
    init() {
        NotificationService.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(db)
        }
    }
}

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @EnvironmentObject var db: DatabaseManager
    
    var body: some View {
        if isActive {
            HomeScreen()
                .environmentObject(db)
        } else {
            ZStack {
                Color("Background").ignoresSafeArea() // Crie as cores no Assets ou use .systemBackground
                
                VStack(spacing: 24) {
                    Image(systemName: "rocket.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.appPrimary)
                    
                    Text("Buya Serviços Digitais")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Aplicativos de produtividade")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        self.opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        NotificationService.verificarRegrasELembretes(encomendas: db.encomendas)
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}
