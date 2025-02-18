    //
    //  StatisticService.swift
    //  MovieQuiz
    //
    //  Created by R Kolos on 02.02.2025.
    //

import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {

    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case bestGameTotal
        case bestGameDate
    }

    private let storage = UserDefaults.standard

    private var correct: Int {
        get {
            return storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }

    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var totalAccuracy: Double {
        return gamesCount == 0 ? 0.0 : Double(correct) / Double(gamesCount * 10) * 100.0
    }

    func store(correct count: Int, total amount: Int) {
        let newGame = GameResult(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
        correct += count
        gamesCount += 1
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGame.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGame.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
}
