//
//  GameResult.swift
//  MovieQuiz
//
//  Created by R Kolos on 04.02.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    // сравнение по количеству ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        return self.correct > another.correct
    }
}
