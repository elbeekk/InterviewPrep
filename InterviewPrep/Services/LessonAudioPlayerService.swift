import AVFoundation
import Foundation
import MediaPlayer
import UIKit

@Observable
final class LessonAudioPlayerService: NSObject {
    enum PlaybackState {
        case idle
        case playing
        case paused
    }

    private struct WordTiming {
        let range: NSRange
        let startTime: TimeInterval
        let endTime: TimeInterval
    }

    private struct SectionMapping {
        let sectionId: String
        let startLocation: Int
        let endLocation: Int
    }

    private struct PreparedLessonAudio {
        let nsText: NSString
        let words: [WordTiming]
        let totalDuration: TimeInterval
        let sectionMappings: [SectionMapping]

        func elapsedTime(forCharacterLocation characterLocation: Int) -> TimeInterval {
            guard !words.isEmpty else { return 0 }

            let boundedLocation = max(0, min(characterLocation, nsText.length))
            let index = wordIndex(forCharacterLocation: boundedLocation)
            return words[index].startTime
        }

        func characterLocation(forElapsedTime elapsedTime: TimeInterval) -> Int {
            guard !words.isEmpty else { return 0 }

            let boundedTime = max(0, min(elapsedTime, totalDuration))
            guard let word = words.first(where: { boundedTime < $0.endTime }) else {
                return nsText.length
            }

            return word.range.location
        }

        private func wordIndex(forCharacterLocation characterLocation: Int) -> Int {
            for (index, word) in words.enumerated().reversed() {
                if characterLocation >= word.range.location {
                    return index
                }
            }

            return 0
        }
    }

    private let synthesizer = AVSpeechSynthesizer()
    private var hasConfiguredRemoteCommands = false
    private var needsRestartFromCurrentLesson = false
    private var preparedAudioCache: [String: PreparedLessonAudio] = [:]
    private var currentPreparedAudio: PreparedLessonAudio?
    private var currentSpeechCharacterLocation = 0
    private var currentUtteranceBaseCharacterLocation = 0
    private var activeUtterance: AVSpeechUtterance?
    private var queuedUtterances: Set<ObjectIdentifier> = []
    private var utteranceBaseOffsets: [ObjectIdentifier: Int] = [:]
    private var speechGeneration: UInt = 0

    private(set) var queue: [Lesson] = []
    private(set) var currentIndex: Int?
    private(set) var currentLesson: Lesson?
    private(set) var playbackState: PlaybackState = .idle
    private(set) var activeSectionId: String?

    var isMiniPlayerVisible: Bool {
        currentLesson != nil
    }

    var isPlaying: Bool {
        playbackState == .playing
    }

    var isPaused: Bool {
        playbackState == .paused
    }

    var canGoNext: Bool {
        guard let currentIndex else { return false }
        return currentIndex + 1 < queue.count
    }

    var canGoPrevious: Bool {
        guard let currentIndex else { return false }
        return currentIndex > 0
    }

    var canSkipForward: Bool {
        currentLesson != nil
    }

    var currentTitle: String {
        currentLesson?.compactListTitle ?? ""
    }

    var currentSubtitle: String {
        guard let lesson = currentLesson else { return "" }

        if queue.count > 1, let currentIndex {
            return "\(currentIndex + 1) of \(queue.count) • \(topicDisplayName(from: lesson.topic))"
        }

        return "\(lesson.track.shortDisplayName) • \(topicDisplayName(from: lesson.topic))"
    }

    var currentTrackIcon: String {
        currentLesson?.track.icon ?? "speaker.wave.2.fill"
    }

    override init() {
        super.init()
        synthesizer.delegate = self
        configureRemoteCommandsIfNeeded()
    }

    func isCurrentLesson(_ lesson: Lesson) -> Bool {
        currentLesson?.id == lesson.id
    }

    func togglePlayback(for lesson: Lesson, queue: [Lesson]) {
        let normalizedQueue = normalizedQueue(containing: lesson, queue: queue)

        if isCurrentLesson(lesson), self.queue.map(\.id) == normalizedQueue.map(\.id) {
            togglePlayPause()
            return
        }

        play(lesson: lesson, queue: normalizedQueue)
    }

    func play(lesson: Lesson, queue: [Lesson]) {
        let normalizedQueue = normalizedQueue(containing: lesson, queue: queue)
        guard let newIndex = normalizedQueue.firstIndex(where: { $0.id == lesson.id }) else { return }

        self.queue = normalizedQueue
        currentIndex = newIndex
        currentLesson = normalizedQueue[newIndex]
        startCurrentLesson()
    }

    func togglePlayPause() {
        switch playbackState {
        case .playing:
            pause()
        case .paused:
            resume()
        case .idle:
            if currentLesson != nil {
                startCurrentLesson()
            }
        }
    }

    func playNextLesson() {
        guard let currentIndex, currentIndex + 1 < queue.count else { return }
        let newIndex = currentIndex + 1
        self.currentIndex = newIndex
        currentLesson = queue[newIndex]
        startCurrentLesson()
    }

    func playPreviousLesson() {
        guard let currentIndex else { return }

        if currentIndex > 0 {
            let newIndex = currentIndex - 1
            self.currentIndex = newIndex
            currentLesson = queue[newIndex]
            startCurrentLesson()
            return
        }

        startCurrentLesson()
    }

    func skipForward(seconds: TimeInterval = 30) {
        guard let currentLesson else { return }

        let preparedAudio = preparedAudio(for: currentLesson)
        let currentElapsed = preparedAudio.elapsedTime(forCharacterLocation: currentSpeechCharacterLocation)
        let targetElapsed = currentElapsed + seconds

        if targetElapsed >= preparedAudio.totalDuration {
            finishCurrentLesson()
            return
        }

        startCurrentLesson(at: targetElapsed)
    }

    func dismissPlayer() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }

        queue = []
        currentIndex = nil
        currentLesson = nil
        playbackState = .idle
        needsRestartFromCurrentLesson = false
        activeUtterance = nil
        queuedUtterances = []
        utteranceBaseOffsets = [:]
        activeSectionId = nil
        currentPreparedAudio = nil
        currentSpeechCharacterLocation = 0
        currentUtteranceBaseCharacterLocation = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        MPNowPlayingInfoCenter.default().playbackState = .stopped
        updateRemoteCommandAvailability()
        deactivateAudioSession()
    }

    private func pause() {
        guard synthesizer.isSpeaking else { return }
        if synthesizer.pauseSpeaking(at: .word) {
            playbackState = .paused
            MPNowPlayingInfoCenter.default().playbackState = .paused
            updateNowPlayingInfo()
            updateRemoteCommandAvailability()
        }
    }

    private func resume() {
        guard currentLesson != nil else { return }
        activateAudioSessionIfNeeded()

        if needsRestartFromCurrentLesson {
            startCurrentLesson()
            return
        }

        if synthesizer.isPaused, synthesizer.continueSpeaking() {
            playbackState = .playing
            MPNowPlayingInfoCenter.default().playbackState = .playing
            updateNowPlayingInfo()
            updateRemoteCommandAvailability()
        } else {
            startCurrentLesson()
        }
    }

    private func startCurrentLesson() {
        startCurrentLesson(at: 0)
    }

    private func startCurrentLesson(at elapsedTime: TimeInterval) {
        guard let currentLesson else { return }
        let preparedAudio = preparedAudio(for: currentLesson)
        let startLocation = preparedAudio.characterLocation(forElapsedTime: elapsedTime)

        guard startLocation < preparedAudio.nsText.length else {
            finishCurrentLesson()
            return
        }

        activateAudioSessionIfNeeded()

        // Increment generation and clear tracking BEFORE stopping
        // so stale didFinish callbacks from old utterances are ignored
        speechGeneration &+= 1
        queuedUtterances = []
        utteranceBaseOffsets = [:]

        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let remainingText = preparedAudio.nsText.substring(from: startLocation)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !remainingText.isEmpty else {
            finishCurrentLesson()
            return
        }

        // Split into chunks to avoid AVSpeechSynthesizer silently stopping on long text
        let chunks = splitIntoChunks(remainingText, maxLength: 800)
        guard !chunks.isEmpty else {
            finishCurrentLesson()
            return
        }

        currentPreparedAudio = preparedAudio
        currentUtteranceBaseCharacterLocation = startLocation
        currentSpeechCharacterLocation = startLocation
        needsRestartFromCurrentLesson = false

        // Track position in the original NSString for each chunk
        var chunkBaseOffset = startLocation
        var isFirst = true
        var lastUtterance: AVSpeechUtterance?

        for chunk in chunks {
            let utterance = AVSpeechUtterance(string: chunk)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.48
            utterance.prefersAssistiveTechnologySettings = true
            utterance.preUtteranceDelay = isFirst ? 0.15 : 0.05
            utterance.postUtteranceDelay = 0.05

            let uttId = ObjectIdentifier(utterance)
            queuedUtterances.insert(uttId)
            utteranceBaseOffsets[uttId] = chunkBaseOffset
            lastUtterance = utterance
            synthesizer.speak(utterance)

            // Advance base: chunk length + any whitespace between chunks
            chunkBaseOffset += (chunk as NSString).length
            let nsFullText = preparedAudio.nsText
            while chunkBaseOffset < nsFullText.length,
                  let scalar = Unicode.Scalar(nsFullText.character(at: chunkBaseOffset)),
                  CharacterSet.whitespacesAndNewlines.contains(scalar) {
                chunkBaseOffset += 1
            }
            isFirst = false
        }

        activeUtterance = lastUtterance
        playbackState = .playing
        MPNowPlayingInfoCenter.default().playbackState = .playing
        updateNowPlayingInfo()
        updateRemoteCommandAvailability()
    }

    private func finishCurrentLesson() {
        guard currentLesson != nil else { return }

        if canGoNext {
            playNextLesson()
            return
        }

        // Queue finished — dismiss the player and clear Now Playing
        dismissPlayer()
    }

    private func normalizedQueue(containing lesson: Lesson, queue: [Lesson]) -> [Lesson] {
        let source = queue.isEmpty ? [lesson] : queue
        var seen = Set<String>()
        let deduplicated = source.filter { seen.insert($0.id).inserted }

        if deduplicated.contains(where: { $0.id == lesson.id }) {
            return deduplicated
        }

        return [lesson] + deduplicated
    }

    private func configureRemoteCommandsIfNeeded() {
        guard !hasConfiguredRemoteCommands else { return }
        hasConfiguredRemoteCommands = true

        UIApplication.shared.beginReceivingRemoteControlEvents()

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        commandCenter.nextTrackCommand.removeTarget(nil)
        commandCenter.previousTrackCommand.removeTarget(nil)
        commandCenter.skipForwardCommand.removeTarget(nil)

        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.resume()
            return self.currentLesson == nil ? .commandFailed : .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.pause()
            return self.currentLesson == nil ? .commandFailed : .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.togglePlayPause()
            return self.currentLesson == nil ? .commandFailed : .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self, self.canGoNext else { return .commandFailed }
            self.playNextLesson()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self, self.currentLesson != nil else { return .commandFailed }
            self.playPreviousLesson()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = false
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self, self.currentLesson != nil else { return .commandFailed }
            self.skipForward()
            return .success
        }
        commandCenter.skipBackwardCommand.isEnabled = false
        updateRemoteCommandAvailability()
    }

    private func updateRemoteCommandAvailability() {
        let commandCenter = MPRemoteCommandCenter.shared()
        let hasLesson = currentLesson != nil

        commandCenter.playCommand.isEnabled = hasLesson && playbackState != .playing
        commandCenter.pauseCommand.isEnabled = hasLesson && playbackState == .playing
        commandCenter.togglePlayPauseCommand.isEnabled = hasLesson
        commandCenter.nextTrackCommand.isEnabled = canGoNext
        commandCenter.previousTrackCommand.isEnabled = hasLesson
        commandCenter.skipForwardCommand.isEnabled = hasLesson
    }

    private func updateNowPlayingInfo() {
        guard let currentLesson else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentLesson.title,
            MPMediaItemPropertyArtist: currentLesson.track.displayName,
            MPMediaItemPropertyAlbumTitle: topicDisplayName(from: currentLesson.topic),
            MPNowPlayingInfoPropertyPlaybackRate: playbackState == .playing ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
        ]

        if let preparedAudio = currentPreparedAudio {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = preparedAudio.totalDuration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] =
                preparedAudio.elapsedTime(forCharacterLocation: currentSpeechCharacterLocation)
        }

        if let artwork = artwork(for: currentLesson) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func artwork(for lesson: Lesson) -> MPMediaItemArtwork? {
        let configuration = UIImage.SymbolConfiguration(pointSize: 88, weight: .semibold)
        guard
            let image = UIImage(systemName: lesson.track.icon, withConfiguration: configuration)?
                .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        else {
            return nil
        }

        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }

    private func speakableTextWithMappings(for lesson: Lesson) -> (String, [SectionMapping]) {
        var segments: [(text: String, sectionId: String?)] = [
            (lesson.title, nil),
            ("Difficulty: \(lesson.difficulty.displayName).", nil),
        ]

        for section in lesson.content {
            segments.append(("\(clean(section.heading)). \(clean(section.body))", section.id))
        }

        if !lesson.codeExamples.isEmpty {
            let examples = lesson.codeExamples.map { "\(clean($0.title)). \(clean($0.explanation))" }
            segments.append(("Examples. \(examples.joined(separator: " "))", nil))
        }

        if !lesson.keyTakeaways.isEmpty {
            let takeaways = lesson.keyTakeaways.enumerated().map { "Takeaway \($0 + 1). \(clean($1))" }
            segments.append(("Key takeaways. \(takeaways.joined(separator: " "))", nil))
        }

        let fullText = segments.map(\.text).joined(separator: " ")
        var mappings: [SectionMapping] = []
        var charOffset = 0

        for segment in segments {
            let segmentLength = (segment.text as NSString).length
            if let sectionId = segment.sectionId {
                mappings.append(SectionMapping(
                    sectionId: sectionId,
                    startLocation: charOffset,
                    endLocation: charOffset + segmentLength
                ))
            }
            charOffset += segmentLength + 1 // +1 for " " separator
        }

        return (fullText, mappings)
    }

    private func preparedAudio(for lesson: Lesson) -> PreparedLessonAudio {
        if let cached = preparedAudioCache[lesson.id] {
            currentPreparedAudio = cached
            return cached
        }

        let (text, sectionMappings) = speakableTextWithMappings(for: lesson)
        let nsText = text as NSString
        let matches = NSRegularExpression.wordPattern.matches(
            in: text,
            range: NSRange(location: 0, length: nsText.length)
        )

        var words: [WordTiming] = []
        var currentTime: TimeInterval = 0

        for match in matches {
            let word = nsText.substring(with: match.range)
            let duration = estimatedDuration(for: word)
            words.append(
                WordTiming(
                    range: match.range,
                    startTime: currentTime,
                    endTime: currentTime + duration
                )
            )
            currentTime += duration
        }

        let preparedAudio = PreparedLessonAudio(
            nsText: nsText,
            words: words,
            totalDuration: currentTime,
            sectionMappings: sectionMappings
        )
        preparedAudioCache[lesson.id] = preparedAudio
        currentPreparedAudio = preparedAudio
        return preparedAudio
    }

    private func clean(_ text: String) -> String {
        text
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func estimatedDuration(for word: String) -> TimeInterval {
        let trimmed = word.trimmingCharacters(in: .punctuationCharacters)
        let baseWordDuration = 60.0 / 175.0
        let lengthAdjustment = Double(min(max(trimmed.count, 1), 12)) * 0.012

        var punctuationPause: TimeInterval = 0
        if word.contains(".") || word.contains("!") || word.contains("?") || word.contains(":") {
            punctuationPause += 0.18
        } else if word.contains(",") || word.contains(";") {
            punctuationPause += 0.1
        }

        return baseWordDuration + lengthAdjustment + punctuationPause
    }

    private func topicDisplayName(from rawTopic: String) -> String {
        rawTopic
            .split(separator: "_")
            .map { token in
                switch token.lowercased() {
                case "api": "API"
                case "oop": "OOP"
                case "ui": "UI"
                case "ux": "UX"
                case "mvvm": "MVVM"
                case "ci": "CI"
                case "cd": "CD"
                default: token.capitalized
                }
            }
            .joined(separator: " ")
    }

    private func splitIntoChunks(_ text: String, maxLength: Int) -> [String] {
        guard text.count > maxLength else { return [text] }

        var chunks: [String] = []
        var remaining = text

        while !remaining.isEmpty {
            if remaining.count <= maxLength {
                chunks.append(remaining)
                break
            }

            // Find a sentence boundary near maxLength
            let searchEnd = remaining.index(remaining.startIndex, offsetBy: maxLength)
            let searchRange = remaining.startIndex..<searchEnd
            var splitIndex = searchEnd

            // Try to split at sentence end (. ! ?)
            if let lastSentenceEnd = remaining.range(of: #"[.!?]\s"#, options: [.regularExpression, .backwards], range: searchRange)?.upperBound {
                splitIndex = lastSentenceEnd
            }

            let chunk = String(remaining[remaining.startIndex..<splitIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !chunk.isEmpty {
                chunks.append(chunk)
            }
            remaining = String(remaining[splitIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return chunks
    }

    private func updateActiveSectionId() {
        guard let mappings = currentPreparedAudio?.sectionMappings else {
            activeSectionId = nil
            return
        }
        activeSectionId = mappings.first {
            currentSpeechCharacterLocation >= $0.startLocation && currentSpeechCharacterLocation < $0.endLocation
        }?.sectionId
    }

    private func activateAudioSessionIfNeeded() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.allowAirPlay, .allowBluetoothHFP])
            try session.setActive(true)
            MPNowPlayingInfoCenter.default().playbackState = .playing
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
}

extension LessonAudioPlayerService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        let baseOffset = utteranceBaseOffsets[ObjectIdentifier(utterance)] ?? currentUtteranceBaseCharacterLocation
        currentUtteranceBaseCharacterLocation = baseOffset
        currentSpeechCharacterLocation = baseOffset + characterRange.location
        updateActiveSectionId()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let generation = self.speechGeneration
        DispatchQueue.main.async { [weak self] in
            guard let self, generation == self.speechGeneration else { return }
            let id = ObjectIdentifier(utterance)
            guard self.queuedUtterances.contains(id) else { return }
            self.queuedUtterances.remove(id)
            self.utteranceBaseOffsets.removeValue(forKey: id)

            if self.queuedUtterances.isEmpty {
                self.finishCurrentLesson()
            } else {
                self.updateNowPlayingInfo()
            }
        }
    }
}

private extension NSRegularExpression {
    static let wordPattern = try! NSRegularExpression(pattern: #"\S+"#)
}
