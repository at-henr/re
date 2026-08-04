import SwiftUI

struct AppParceiro: Identifiable {
    let id = UUID()
    let nome: String
    let imagem: String
    let link: String
    let descricao: String
    let botaoText: String
}

struct InfoScreen: View {
    @Environment(\.colorScheme) var colorScheme
    
    let parceiros = [
        AppParceiro(nome: "DendiHome", imagem: "dendi", link: "https://www.dendihome.com/aplicativo", descricao: "Plataforma Exclusiva\n\nA Evolução do Streaming. Sem Interrupções. Filmes em 4K, séries aclamadas e TV ao vivo. Projetado para máxima performance no seu Android e TV Box.", botaoText: "Acessar Site"),
        AppParceiro(nome: "Yih Chat", imagem: "yihchat", link: "https://yih.com.br/", descricao: "O Segredo em forma de Sussurro.\n\nComunicação instantânea onde sua identidade é protegida e suas mensagens são efêmeras. Fale o que quiser, para quem quiser.", botaoText: "Acessar Site"),
        AppParceiro(nome: "Financio", imagem: "financio", link: "https://play.google.com/store/apps/details?id=com.rmn.financio", descricao: "O Financio é uma ferramenta pessoal desenvolvida para quem busca clareza, praticidade e controle real sobre o próprio orçamento. Com uma interface moderna, limpa e totalmente intuitiva, o aplicativo ajuda você a monitorar seus gastos diários, traçar metas de economia e entender seus hábitos de consumo sem a complexidade das planilhas tradicionais.", botaoText: "Ver na Play Store"),
        AppParceiro(nome: "Koru", imagem: "Koru", link: "https://play.google.com/store/apps/details?id=com.rmn.rotina", descricao: "O Projeto Koru é um aplicativo móvel projetado para otimizar a gestão de rotina e facilitar a formação de hábitos através de um sistema robusto de gamificação. Inspirado na filosofia Maori do \"broto de samambaia\", o Koru visa motivar o usuário, transformando o tedioso monitoramento de tarefas em um desafio recompensador.", botaoText: "Ver na Play Store"),
        AppParceiro(nome: "App de Delivery", imagem: "delivery", link: "https://wa.me/qr/6Y7PA4T4ZVYSD1", descricao: "A melhor experiência em delivery. Comida rápida, quente e com o melhor sabor direto na sua porta.", botaoText: "Solicite o seu!")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header Empresa
                VStack(spacing: 12) {
                    Image(systemName: "rocket.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.appPrimary)
                    
                    Text("Buya Serviços Digitais")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Otimizando o seu tempo e construindo inovações.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "headphones")
                            Text("financio@usa.com")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appPrimary, lineWidth: 1)
                        )
                    }
                    .foregroundColor(.appPrimary)
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                Text("Conheça Nossos Apps Parceiros")
                    .font(.headline)
                
                // Cards de Parceiros
                ForEach(parceiros) { app in
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ZStack {
                            Color(UIColor.tertiarySystemBackground)
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            // Exige que você adicione as imagens aos Assets do Xcode (Assets.xcassets)
                            Image(app.imagem)
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(height: 160)
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(app.nome)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(app.descricao)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                            
                            Button(action: {
                                if let url = URL(string: app.link), !app.link.isEmpty {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: app.link.isEmpty ? "lock.fill" : "arrow.up.right.square")
                                    Text(app.botaoText)
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(app.link.isEmpty ? Color.gray : Color.appGreen)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(app.link.isEmpty)
                            .padding(.top, 8)
                        }
                        .padding()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
                
                Divider()
                    .padding(.vertical)
                
                Text("© \(Calendar.current.component(.year, from: Date())) Buya Serviços Digitais")
                    .fontWeight(.bold)
                Text("Apps de produtividade.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
            }
            .padding()
        }
        .navigationTitle("Sobre & Parceiros")
        .navigationBarTitleDisplayMode(.inline)
    }
}
