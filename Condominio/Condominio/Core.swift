import Foundation
import SwiftUI
import UserNotifications

// MARK: - Extensão de Cores
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
    
    static let appPrimary = Color(hex: "FF9900")
    static let appSecondary = Color(hex: "D32F2F")
    static let appGreen = Color(hex: "2E7D32")
}

// MARK: - Modelo
struct Encomenda: Identifiable, Codable, Hashable {
    var id: String
    var bloco: String
    var apartamento: String
    var destinatario: String?
    var dataEntrada: String
    var receptor: String?
    var dataSaida: String?
}

// MARK: - Banco de Dados (UserDefaults)
class DatabaseManager: ObservableObject {
    @Published var encomendas: [Encomenda] = []
    private let dbKey = "caixa_entregas_db"
    
    init() {
        carregarDados()
    }
    
    func salvarDados() {
        if let encoded = try? JSONEncoder().encode(encomendas) {
            UserDefaults.standard.set(encoded, forKey: dbKey)
        }
    }
    
    func carregarDados() {
        if let data = UserDefaults.standard.data(forKey: dbKey),
           let decoded = try? JSONDecoder().decode([Encomenda].self, from: data) {
            self.encomendas = decoded
        }
    }
    
    func deletar(encomenda: Encomenda) {
        encomendas.removeAll { $0.id == encomenda.id }
        salvarDados()
    }
}

// MARK: - Notificações
class NotificationService {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    static func dispararNotificacao(titulo: String, mensagem: String) {
        let content = UNMutableNotificationContent()
        content.title = titulo
        content.body = mensagem
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "lembrete_portaria", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    static func verificarRegrasELembretes(encomendas: [Encomenda]) {
        let hora = Calendar.current.component(.hour, from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let hoje = dateFormatter.string(from: Date())
        let defaults = UserDefaults.standard
        
        // Regra 1: Silêncio (0h as 7h59)
        if hora >= 0 && hora < 8 { return }
        
        // Regra 2: Bom dia
        let ultimoBomDia = defaults.string(forKey: "ULTIMO_BOM_DIA")
        if ultimoBomDia != hoje {
            dispararNotificacao(titulo: "☀️ Bom dia!", mensagem: "Lembre-se de registrar as novas encomendas no aplicativo assim que chegarem.")
            defaults.set(hoje, forKey: "ULTIMO_BOM_DIA")
            return
        }
        
        // Regra 3: Pendências
        let pendentes = encomendas.filter { $0.dataSaida == nil }.count
        let ultimaQtd = defaults.integer(forKey: "ULTIMA_QTD_PENDENTES")
        
        if pendentes == 0 {
            defaults.set(0, forKey: "ULTIMA_QTD_PENDENTES")
        } else if pendentes > 0 && pendentes != ultimaQtd {
            dispararNotificacao(titulo: "📱 Lembrete", mensagem: "Você tem \(pendentes) pacote(s) pendente(s). Lembre-se de dar baixa quando buscarem.")
            defaults.set(pendentes, forKey: "ULTIMA_QTD_PENDENTES")
        }
    }
}

// MARK: - Extensão para remover acentos
extension String {
    func semAcentos() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}
