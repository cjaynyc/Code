import Foundation

// MARK: - 90-Day Fluency Pathway

/// Tracks progress through the 90-day fluency pathway.
struct FluencyTracker: Codable, Equatable {
    var currentPhase: LearningPhase
    var dayNumber: Int
    var wordsIntroduced: [String]
    var wordsMastered: [String]
    /// Calculated from mastered roots and compound derivation rules
    var derivableWordCount: Int
    var streakDays: Int
    var totalPracticeMinutes: Double
    var dailyLog: [DailyPractice]

    init(
        currentPhase: LearningPhase = .foundation,
        dayNumber: Int = 1,
        wordsIntroduced: [String] = [],
        wordsMastered: [String] = [],
        derivableWordCount: Int = 0,
        streakDays: Int = 0,
        totalPracticeMinutes: Double = 0,
        dailyLog: [DailyPractice] = []
    ) {
        self.currentPhase = currentPhase
        self.dayNumber = dayNumber
        self.wordsIntroduced = wordsIntroduced
        self.wordsMastered = wordsMastered
        self.derivableWordCount = derivableWordCount
        self.streakDays = streakDays
        self.totalPracticeMinutes = totalPracticeMinutes
        self.dailyLog = dailyLog
    }
}

enum LearningPhase: String, Codable {
    /// Days 1-30, target 10 core words
    case foundation
    /// Days 31-60, target 30 words
    case expansion
    /// Days 61-90, target 50 words
    case fluency
    /// Post-90, ongoing evolution
    case mastery
}

struct DailyPractice: Codable, Equatable {
    var date: Date
    var minutesPracticed: Double
    var wordsReviewed: Int
    var newWordsIntroduced: Int
    var challengesCompleted: Int
    var xpEarned: Int
}

// MARK: - Spaced Repetition

/// Retention schedule for a single word using spaced repetition.
struct RetentionSchedule: Codable, Equatable {
    var wordId: String
    /// Days until next review
    var currentInterval: TimeInterval
    var nextReviewDate: Date
    /// Streak of consecutive correct recalls
    var consecutiveCorrect: Int
    var totalReviews: Int
    /// Type of review last used (for varied retrieval)
    var lastReviewType: ReviewType
    /// Times the word appeared organically in chat/scenarios
    var organicEncounters: Int
    /// 0-1 decay risk, increases as review deadline approaches
    var decayRisk: Double

    init(
        wordId: String,
        currentInterval: TimeInterval = 86400, // 1 day
        nextReviewDate: Date = Date().addingTimeInterval(86400),
        consecutiveCorrect: Int = 0,
        totalReviews: Int = 0,
        lastReviewType: ReviewType = .translation,
        organicEncounters: Int = 0,
        decayRisk: Double = 0
    ) {
        self.wordId = wordId
        self.currentInterval = currentInterval
        self.nextReviewDate = nextReviewDate
        self.consecutiveCorrect = consecutiveCorrect
        self.totalReviews = totalReviews
        self.lastReviewType = lastReviewType
        self.organicEncounters = organicEncounters
        self.decayRisk = decayRisk
    }
}

/// Review method used for varied retrieval during spaced repetition.
enum ReviewType: String, Codable {
    case codebreakers
    case translation
    case reverseTranslation
    case audioRecognition
    case rootIdentification
    case sentenceBuilding
    case speedRound
}
