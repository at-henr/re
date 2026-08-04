import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var db: DatabaseManager
    @State private var searchText = ""
    @State private var filterBloco = "Todos"
    @State private var filterApto = "Todos"
    @State private var showingAddScreen = false
    @State private var isBlinking = false
    
    // Arrays blindados para os filtros
    let blocosDisponiveis = (1...16).map { String($0) }
    let aptosDisponiveis = [
        "101", "102", "103", "104",
        "201", "202", "203", "204",
        "301", "302", "303", "304",
        "401", "402", "403", "404"
    ]
    
    var encomendasPendentes: [String: [Encomenda]] {
        var pendentes = db.encomendas.filter { $0.dataSaida == nil }
        
        // Filtro exato via Picker (Menu Suspenso)
        if filterBloco != "Todos" {
            pendentes = pendentes.filter { $0.bloco == filterBloco }
        }
        
        if filterApto != "Todos" {
            pendentes = pendentes.filter { $0.apartamento == filterApto }
        }
        
        // Busca de texto apenas para Nomes, ignorando acentos e maiúsculas/minúsculas
        if !searchText.isEmpty {
            let termoNormalizado = searchText.semAcentos()
            pendentes = pendentes.filter {
                ($0.destinatario?.semAcentos().contains(termoNormalizado) ?? false) ||
                ($0.receptor?.semAcentos().contains(termoNormalizado) ?? false)
            }
        }
        
        pendentes.sort { $0.id > $1.id }
        return Dictionary(grouping: pendentes, by: { "\($0.bloco)-\($0.apartamento)" })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Área de Filtros
                VStack(spacing: 12) {
                    HStack {
                        Picker("Bloco", selection: $filterBloco) {
                            Text("Todos Blocos").tag("Todos")
                            ForEach(blocosDisponiveis, id: \.self) { b in
                                Text("Bloco \(b)").tag(b)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        
                        Picker("Apto", selection: $filterApto) {
                            Text("Todos Aptos").tag("Todos")
                            ForEach(aptosDisponiveis, id: \.self) { a in
                                Text("Apto \(a)").tag(a)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Pesquisar por Nome...", text: $searchText)
                            .disableAutocorrection(true)
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .padding()
                
                // Lista
                if encomendasPendentes.isEmpty {
                    Spacer()
                    Text("Nenhuma encomenda pendente.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(encomendasPendentes.keys.sorted(), id: \.self) { key in
                            let grupo = encomendasPendentes[key]!
                            let ref = grupo.first!
                            
                            NavigationLink(destination: DetalhesEncomendaView(encomendas: grupo)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("\(grupo.count)")
                                            .font(.headline)
                                            .foregroundColor(.appSecondary)
                                            .padding(10)
                                            .background(Color.appSecondary.opacity(0.2))
                                            .clipShape(Circle())
                                        
                                        Text("Bloco \(ref.bloco) - Apto \(ref.apartamento)")
                                            .font(.headline)
                                    }
                                    
                                    ForEach(grupo) { pacote in
                                        HStack {
                                            Image(systemName: "shippingbox")
                                            Text(pacote.destinatario ?? pacote.receptor ?? "Não informado")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Botão Nova Encomenda
                Button(action: { showingAddScreen = true }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("NOVA ENCOMENDA")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("REGISTRO DE ENTREGAS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: InfoScreen()) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.appPrimary)
                            .opacity(isBlinking ? 0.3 : 1.0)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                                    isBlinking.toggle()
                                }
                            }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HistoricoScreen()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(Color.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddScreen) {
                AddPackageScreen()
                    .environmentObject(db)
            }
        }
    }
}

// MARK: - Detalhes / Baixa da Encomenda
struct DetalhesEncomendaView: View {
    @EnvironmentObject var db: DatabaseManager
    @Environment(\.presentationMode) var presentationMode
    
    let encomendas: [Encomenda]
    @State private var selecionadas: Set<String> = []
    @State private var retiranteNome: String = ""
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Bloco \(encomendas.first?.bloco ?? "") - Apto \(encomendas.first?.apartamento ?? "")").font(.title3)) {
                    
                    Button("Marcar/Desmarcar Todos") {
                        if selecionadas.count == encomendas.count {
                            selecionadas.removeAll()
                        } else {
                            selecionadas = Set(encomendas.map { $0.id })
                        }
                    }
                    .foregroundColor(.appPrimary)
                    
                    ForEach(encomendas) { pacote in
                        HStack {
                            Image(systemName: selecionadas.contains(pacote.id) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selecionadas.contains(pacote.id) ? .appPrimary : .gray)
                                .onTapGesture {
                                    if selecionadas.contains(pacote.id) {
                                        selecionadas.remove(pacote.id)
                                    } else {
                                        selecionadas.insert(pacote.id)
                                    }
                                }
                            
                            VStack(alignment: .leading) {
                                Text(pacote.destinatario ?? pacote.receptor ?? "Não informado")
                                    .fontWeight(.bold)
                                Text("🕒 Chegada: \(pacote.dataEntrada)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section {
                    TextField("Nome de quem está retirando", text: $retiranteNome)
                }
            }
            
            Button(action: confirmarBaixa) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("CONFIRMAR \(selecionadas.count) BAIXA(S)")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(selecionadas.isEmpty ? Color.gray : Color.appGreen)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .disabled(selecionadas.isEmpty)
        }
        .navigationTitle("Entregar (\(encomendas.count))")
        .onAppear {
            selecionadas = Set(encomendas.map { $0.id })
        }
    }
    
    private func confirmarBaixa() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dataAgora = formatter.string(from: Date())
        let retirante = retiranteNome.isEmpty ? "Portaria" : retiranteNome
        
        for idSelecionado in selecionadas {
            if let index = db.encomendas.firstIndex(where: { $0.id == idSelecionado }) {
                if (db.encomendas[index].destinatario?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
                    db.encomendas[index].destinatario = db.encomendas[index].receptor
                }
                db.encomendas[index].receptor = retirante
                db.encomendas[index].dataSaida = dataAgora
            }
        }
        
        db.salvarDados()
        presentationMode.wrappedValue.dismiss()
    }
}
