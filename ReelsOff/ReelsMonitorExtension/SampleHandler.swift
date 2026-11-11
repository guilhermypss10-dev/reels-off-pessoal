import Foundation
import ReplayKit
import Vision
import UserNotifications
import CoreImage

/// Prova de conceito: identifica pistas de uma tela de Reels com OCR local.
/// Sem overlays, automação de toques ou restrição de outro aplicativo.
final class SampleHandler: RPBroadcastSampleHandler {
    private let sequenceQueue = DispatchQueue(label: "reelsoff.ocr")
    private var isProcessing = false
    private var lastAnalysis = Date.distantPast
    private var lastNotification = Date.distantPast

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        super.broadcastStarted(withSetupInfo: setupInfo)
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let now = Date()
        guard now.timeIntervalSince(lastAnalysis) >= 1.5, !isProcessing else { return }
        lastAnalysis = now
        isProcessing = true
        // CMSampleBuffer/CVPixelBuffer is retained by the block; serial queue avoids overlapping OCR.
        sequenceQueue.async { [weak self] in
            guard let self else { return }
            defer { self.isProcessing = false }
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .fast
            request.usesLanguageCorrection = false
            do {
                try VNImageRequestHandler(cvPixelBuffer: imageBuffer, options: [:]).perform([request])
                let topLabels: [String] = (request.results ?? []).compactMap { result in
                    // Only near the upper part: "Reels" in bottom navigation is insufficient.
                    guard result.boundingBox.midY >= 0.72 else { return nil }
                    return result.topCandidates(1).first?.string.lowercased()
                }
                let likelyReelsScreen = topLabels.contains { label in
                    let cleaned = label.trimmingCharacters(in: .whitespacesAndNewlines)
                    return cleaned == "reels" || cleaned == "reel"
                }
                if likelyReelsScreen, Date().timeIntervalSince(self.lastNotification) > 45 {
                    self.lastNotification = Date()
                    let content = UNMutableNotificationContent()
                    content.title = "Reels detectado"
                    content.body = "Você entrou na tela de Reels. Volte para o Direct ou publicações."
                    content.sound = .default
                    let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                        content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                }
            } catch {
                NSLog("ReelsOff: OCR não executado: %@", error.localizedDescription)
            }
        }
    }
}
