import SwiftUI

struct AddPackageScreen: View {
    @EnvironmentObject var db: DatabaseManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var bloco = ""
    @State private var apartamento = ""
    @State private var destinatario = ""
    @State private var observacao = ""
    @State private var dataSelecionada = Date()
    @State private var showImagePicker = false
    
    // Arrays blindados com os dados exatos do condomínio
    let blocosDisponiveis = (1...16).map { String($0) }
    
    let aptosDisponiveis = [
        "101", "102", "103", "104",
        "201", "202", "203", "204",
        "301", "302", "303", "304",
        "401", "402", "403", "404"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tirar Foto da Etiqueta (Opcional)")) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Capturar Etiqueta")
                        }
                    }
                }
                
                Section(header: Text("Identificação do Pacote")) {
                    // Pickers no lugar de TextFields para evitar digitação errada
                    Picker("Selecione o Bloco", selection: $bloco) {
                        Text("Selecione...").tag("") // Placeholder
                        ForEach(blocosDisponiveis, id: \.self) { b in
                            Text("Bloco \(b)").tag(b)
                        }
                    }
                    
                    Picker("Selecione o Apartamento", selection: $apartamento) {
                        Text("Selecione...").tag("") // Placeholder
                        ForEach(aptosDisponiveis, id: \.self) { a in
                            Text("Apto \(a)").tag(a)
                        }
                    }
                    
                    TextField("Nome do Destinatário", text: $destinatario)
                }
                
                Section(header: Text("Detalhes da Entrega")) {
                    DatePicker("Data de Entrada", selection: $dataSelecionada)
                    
                    TextField("Informação Adicional (Ex: Mercado Livre)", text: $observacao)
                }
                
                Section {
                    Button(action: salvarEncomenda) {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle")
                            Text("CONFIRMAR E SALVAR")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                    // O botão só fica verde e clicável se Bloco e Apto forem selecionados
                    .listRowBackground(bloco.isEmpty || apartamento.isEmpty ? Color.gray : Color.appGreen)
                    .disabled(bloco.isEmpty || apartamento.isEmpty)
                }
            }
            .navigationTitle("Registro de Encomenda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func salvarEncomenda() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dataStr = formatter.string(from: dataSelecionada)
        
        let obsTexto = observacao.trimmingCharacters(in: .whitespacesAndNewlines)
        let nomeDestinatario = destinatario.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var destinatarioFormatado: String
        if !nomeDestinatario.isEmpty {
            destinatarioFormatado = "\(nomeDestinatario)\n\(obsTexto)"
        } else {
            destinatarioFormatado = "Não informado\n\(obsTexto)"
        }
        
        let novaEncomenda = Encomenda(
            id: UUID().uuidString,
            bloco: bloco.trimmingCharacters(in: .whitespacesAndNewlines),
            apartamento: apartamento.trimmingCharacters(in: .whitespacesAndNewlines),
            destinatario: destinatarioFormatado,
            dataEntrada: dataStr,
            receptor: nil,
            dataSaida: nil
        )
        
        db.encomendas.append(novaEncomenda)
        db.salvarDados()
        
        presentationMode.wrappedValue.dismiss()
    }
}
