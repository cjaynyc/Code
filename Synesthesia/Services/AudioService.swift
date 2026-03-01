import Foundation
import AVFoundation

/// Text-to-speech service for conlang pronunciation using AVSpeechSynthesizer.
/// Uses SSML for phoneme-level control when available.
final class AudioService: NSObject, ObservableObject {
    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speak text using the default system voice with phoneme hints.
    func speak(_ text: String, rate: Float = 0.4, pitch: Float = 1.0) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Speak using IPA pronunciation via SSML phoneme tags.
    func speakIPA(_ ipa: String, rate: Float = 0.35, pitch: Float = 1.0) {
        stop()
        let ssml = """
        <speak>
            <phoneme alphabet="ipa" ph="\(escapeXML(ipa))">
                \(escapeXML(ipa))
            </phoneme>
        </speak>
        """
        let utterance = AVSpeechUtterance(ssmlRepresentation: ssml)
            ?? AVSpeechUtterance(string: ipa)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Speak a phrase with its romanized text, falling back to IPA if available.
    func speakPhrase(_ phrase: Phrase) {
        if !phrase.pronunciation.isEmpty {
            speakIPA(phrase.pronunciation)
        } else {
            speak(phrase.conlang)
        }
    }

    /// Speak a single phoneme.
    func speakPhoneme(_ phoneme: Phoneme) {
        speakIPA(phoneme.symbol, rate: 0.3)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            isSpeaking = false
        }
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
}
