import Foundation
import ReplayKit
import Vision
import UserNotifications
import CoreVideo

/// Detector experimental de Reels. A extensao apenas reconhece texto e emite avisos.
/// Nao fecha, bloqueia nem modifica a interface de outros aplicativos.
final class SampleHandler: RPBroadcastSampleHandler {
    private let analysisQueue = DispatchQueue(label: "reelsoff.analysis", qos: .utility)
    private let frameLock = NSLock()
    private var framePending = false
    private var lastAnalysis = Date.distantPast
    private var lastAlert = Date.distantPast
    private var consecutiveReelsFrames = 0

    private let analysisInterval: TimeInterval = 2.0
    private let alertCooldown: TimeInterval = 60.0

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        analysisQueue.async { [weak self] in
            self?.lastAnalysis = .distantPast
            self?.consecutiveReelsFrames = 0
        }
    }

    override func broadcastFinished() {
        analysisQueue.async { [weak self] in
            self?.consecutiveReelsFrames = 0
        }
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer,
                                      with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Enfileira no maximo um quadro por vez: evita acumular buffers de video
        // enquanto o OCR esta ocupado. Protegido por lock nos callbacks do ReplayKit.
        frameLock.lock()
        let canQueue = !framePending
        if canQueue { framePending = true }
        frameLock.unlock()
        guard canQueue else { return }
        analysisQueue.async { [weak self, imageBuffer] in
            guard let self else { return }
            defer {
                self.frameLock.lock()
                self.framePending = false
                self.frameLock.unlock()
            }
            let now = Date()
            guard now.timeIntervalSince(self.lastAnalysis) >= self.analysisInterval else { return }
            self.lastAnalysis = now
            self.analyze(imageBuffer)
        }
    }

    private func analyze(_ pixelBuffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            let likelyReels = (request.results ?? []).contains { observation in
                // O titulo da aba fica no topo, nao na barra inferior.
                guard observation.boundingBox.midY > 0.72 else { return false }
                guard let candidate = observation.topCandidates(1).first,
                      candidate.confidence >= 0.35 else { return false }
                let cleaned = candidate.string
                    .folding(options: [.caseInsensitive, .diacriticInsensitive],
                             locale: Locale(identifier: "pt_BR"))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()
                return cleaned == "reels" || cleaned == "reel"
            }

            consecutiveReelsFrames = likelyReels ? consecutiveReelsFrames + 1 : 0
            if consecutiveReelsFrames >= 2,
               Date().timeIntervalSince(lastAlert) >= alertCooldown {
                lastAlert = Date()
                notifyReelsDetected()
            }
        } catch {
            consecutiveReelsFrames = 0
            NSLog("ReelsOff: falha na analise OCR: %@", error.localizedDescription)
        }
    }

    private func notifyReelsDetected() {
        let content = UNMutableNotificationContent()
        content.title = "Reels detectado"
        content.body = "Voce pode voltar para o feed ou Direct. Este prototipo apenas avisa."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "reelsoff-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                NSLog("ReelsOff: falha ao agendar aviso: %@", error.localizedDescription)
            }
        }
    }
}
