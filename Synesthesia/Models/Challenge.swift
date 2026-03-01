import Foundation

// MARK: - Codebreakers Game Models

/// Result of a single Codebreakers challenge session.
struct ChallengeResult: Codable, Identifiable, Equatable {
    let id: UUID
    var challengeType: ChallengeType
    var difficulty: Difficulty
    /// Unknown words presented in the challenge
    var targetWords: [String]
    var correctGuesses: [String]
    var incorrectGuesses: [String]
    var hintsUsed: Int
    var timeElapsed: TimeInterval
    var xpEarned: Int
    var completedAt: Date

    init(
        id: UUID = UUID(),
        challengeType: ChallengeType,
        difficulty: Difficulty,
        targetWords: [String],
        correctGuesses: [String] = [],
        incorrectGuesses: [String] = [],
        hintsUsed: Int = 0,
        timeElapsed: TimeInterval = 0,
        xpEarned: Int = 0,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.challengeType = challengeType
        self.difficulty = difficulty
        self.targetWords = targetWords
        self.correctGuesses = correctGuesses
        self.incorrectGuesses = incorrectGuesses
        self.hintsUsed = hintsUsed
        self.timeElapsed = timeElapsed
        self.xpEarned = xpEarned
        self.completedAt = completedAt
    }
}

enum ChallengeType: String, Codable {
    case sentenceDecoder
    case conversationIntercept
    case rootHunter
    case speedRound
    case collaborativeDecode
}

enum Difficulty: String, Codable {
    /// 4:1 known:unknown ratio
    case beginner
    /// 3:2 known:unknown ratio
    case intermediate
    /// 2:3 known:unknown ratio
    case advanced
    /// 1:4 known:unknown ratio
    case master
}

// MARK: - Vocabulary Mastery

/// Tracks mastery progress across all vocabulary.
struct VocabularyMasteryTracker: Codable, Equatable {
    /// Map of conlang word to its mastery data
    var entries: [String: WordMastery]

    init(entries: [String: WordMastery] = [:]) {
        self.entries = entries
    }
}

/// Mastery data for a single word.
struct WordMastery: Codable, Equatable {
    var level: MasteryLevel
    var timesEncountered: Int
    var timesCorrect: Int
    var timesIncorrect: Int
    var averageResponseTime: TimeInterval
    var lastSeen: Date
    /// Spaced repetition scheduling
    var nextReviewDate: Date

    init(
        level: MasteryLevel = .unseen,
        timesEncountered: Int = 0,
        timesCorrect: Int = 0,
        timesIncorrect: Int = 0,
        averageResponseTime: TimeInterval = 0,
        lastSeen: Date = Date(),
        nextReviewDate: Date = Date()
    ) {
        self.level = level
        self.timesEncountered = timesEncountered
        self.timesCorrect = timesCorrect
        self.timesIncorrect = timesIncorrect
        self.averageResponseTime = averageResponseTime
        self.lastSeen = lastSeen
        self.nextReviewDate = nextReviewDate
    }
}

enum MasteryLevel: Int, Codable {
    /// Never encountered in a game
    case unseen = 0
    /// Seen but not guessed correctly
    case encountered = 1
    /// Guessed with hints
    case recognized = 2
    /// Guessed without hints once
    case known = 3
    /// Guessed without hints 3+ times
    case mastered = 4
    /// Speed round correct, <2 seconds
    case fluent = 5
}
