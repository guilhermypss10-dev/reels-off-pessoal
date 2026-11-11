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
    @State private var notificationsAllowed = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 14) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reels Off").font(.largeTitle.bold())
                        Text("Protótipo pessoal de detecção")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Label("1. Permitir notificações", systemImage: "bell")
                        .font(.headline)
                    Text("O detector experimental envia um aviso quando identifica uma tela de Reels. Ainda não fecha ou bloqueia o Instagram.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button(notificationsAllowed ? "Permissão solicitada" : "Solicitar permissão") {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            DispatchQueue.main.async { notificationsAllowed = granted }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Label("2. Iniciar o monitoramento", systemImage: "record.circle")
                        .font(.headline)
                    Text("Toque no ícone de transmissão e selecione ReelsMonitorExtension. O iOS mostrará um aviso de captura de tela.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    BroadcastStartButton()
                        .frame(width: 90, height: 56)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Label("3. Abra o Instagram original", systemImage: "camera")
                        .font(.headline)
                    Text("Teste Reels, Direct e Stories. A análise é feita no iPhone, sem enviar imagens a servidores.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()

                Spacer()
                Text("EXPERIMENTAL • Não bloqueia Reels ainda")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
