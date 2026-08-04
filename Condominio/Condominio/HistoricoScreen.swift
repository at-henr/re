import SwiftUI

struct HistoricoScreen: View {
    @EnvironmentObject var db: DatabaseManager
    @State private var filterBloco = ""
    @State private var searchText = ""
    
    var historicoCompleto: [Encomenda] {
        let finalizados = db.encomendas.filter { $0.dataSaida != nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        return finalizados.sorted { a, b in
            let dateA = formatter.date(from: a.dataSaida ?? "") ?? Date.distantPast
            let dateB = formatter.date(from: b.dataSaida ?? "") ?? Date.distantPast
            return dateA > dateB
        }
    }
    
    var listaFiltrada: [Encomenda] {
        var lista = historicoCompleto
        
        if !filterBloco.isEmpty {
            lista = lista.filter { $0.bloco.semAcentos().contains(filterBloco.semAcentos()) }
        }
        
        if !searchText.isEmpty {
            lista = lista.filter {
                $0.apartamento.semAcentos().contains(searchText.semAcentos()) ||
                ($0.destinatario?.semAcentos().contains(searchText.semAcentos()) ?? false) ||
                ($0.receptor?.semAcentos().contains(searchText.semAcentos()) ?? false)
            }
        }
        
        return lista
    }
    
    var entregasHoje: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let hojeStr = dateFormatter.string(from: Date())
        
        return listaFiltrada.filter { ($0.dataSaida?.prefix(10) ?? "") == hojeStr }.count
    }
    
    var entregasMes: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        let mesAnoStr = dateFormatter.string(from: Date())
        
        return listaFiltrada.filter { ($0.dataSaida?.dropFirst(3).prefix(7) ?? "") == mesAnoStr }.count
    }
    
    var body: some View {
        VStack {
            // Filtros
            HStack {
                TextField("Bloco", text: $filterBloco)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 80)
                
                TextField("Apto ou Nome...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Cards Estatísticas
            HStack {
                EstatisticaCard(titulo: "Neste Mês", valor: "\(entregasMes)", cor: .appGreen)
                EstatisticaCard(titulo: "Entregas Hoje", valor: "\(entregasHoje)", cor: .blue)
            }
            .padding(.horizontal)
            
            // Lista de Histórico
            if listaFiltrada.isEmpty {
                Spacer()
                Text("Nenhum histórico encontrado.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(listaFiltrada) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appGreen)
                            Text("Bloco \(item.bloco) - Apto \(item.apartamento)")
                                .fontWeight(.bold)
                        }
                        
                        Text("Chegada: \(item.dataEntrada)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("Retirada: \(item.dataSaida ?? "")")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.appGreen)
                        
                        Divider()
                        
                        Text("Destinatário: \(item.destinatario ?? "Não informado")")
                            .font(.subheadline)
                        
                        if let rec = item.receptor, !rec.isEmpty {
                            Text("Retirado por: \(rec)")
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Histórico de Entregas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EstatisticaCard: View {
    var titulo: String
    var valor: String
    var cor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(titulo)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            Text(valor)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(cor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
