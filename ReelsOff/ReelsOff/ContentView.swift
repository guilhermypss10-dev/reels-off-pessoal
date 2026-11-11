import SwiftUI
import ReplayKit
import UserNotifications

struct BroadcastStartButton: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.preferredExtension = "com.pessoal.reelsoff.monitor"
        picker.showsMicrophoneButton = false
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}

struct ContentView: View {
    @State private var notificationStatus = "Verificando permissão..."
    @State private var diagnosticMessage = "Nenhum teste realizado"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(.yellow)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reels Off").font(.largeTitle.bold())
                            Text("Detector experimental para iPhone")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 12)

                    Label("Ainda não bloqueia Reels", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))

                    section("1. Notificações", icon: "bell") {
                        Text("Situação: \(notificationStatus)")
                            .font(.subheadline)
                        Button("Solicitar permissão") {
                            UNUserNotificationCenter.current()
                                .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                                    refreshNotificationStatus()
                                }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Enviar notificação de teste") {
                            sendTestNotification()
                        }
                        .buttonStyle(.bordered)
                        Text(diagnosticMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    section("2. Iniciar análise da tela", icon: "record.circle") {
                        Text("Toque no controle, escolha ReelsMonitorExtension e confirme a transmissão do iOS. O conteúdo é analisado localmente.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        BroadcastStartButton()
                            .frame(width: 90, height: 55)
                    }

                    section("3. Conferir no Instagram", icon: "camera") {
                        Text("Abra o Instagram original e compare a aba Reels com Feed, Direct e Stories. O detector tenta emitir um aviso quando reconhece Reels duas vezes seguidas.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Importante: a transmissão também pode capturar mensagens e informações privadas. Encerre-a pelo indicador do iOS quando terminar.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Text("Uso pessoal • Sem conta Instagram • Sem envio de capturas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: refreshNotificationStatus)
    }

    private func section<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon).font(.headline)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .authorized: status = "Permitidas"
            case .provisional: status = "Provisórias"
            case .denied: status = "Negadas (altere em Ajustes)"
            case .notDetermined: status = "Não solicitadas"
            case .ephemeral: status = "Temporárias"
            @unknown default: status = "Desconhecida"
            }
            DispatchQueue.main.async { notificationStatus = status }
        }
    }

    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Teste Reels Off"
        content.body = "As notificações locais estão funcionando."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "reelsoff-test-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        )
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                diagnosticMessage = error == nil
                    ? "Aviso agendado. Coloque o app em segundo plano para conferir."
                    : "Erro: \(error!.localizedDescription)"
            }
        }
    }
}
