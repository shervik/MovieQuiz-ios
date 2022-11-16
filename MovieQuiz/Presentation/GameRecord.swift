//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 14.11.2022.
//

import Foundation

/// correct - количество правильных ответов
/// total - количество вопросов квиза
/// date - дата завершения раунда
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool { // рекорд / текущая
        lhs.correct != rhs.correct ? lhs.correct < rhs.correct : true
    }
}
