//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 14.11.2022.
//

import Foundation

private enum Keys: String {
    case correct, total, bestGame, gamesCount
}

/// totalAccuracy - общая точность игр
/// gamesCount - кол-во сыгранных раундов
/// bestGame - лучшая сыгранная игра (по кол-ву правильных ответов)
/// store - метод сохранения текущего результата игры
protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard

    var totalAccuracy: Double {
        guard let total = userDefaults.double(forKey: Keys.total.rawValue) as Double? else {
            return 0
        }
        return total
    }

    private(set) var gamesCount: Int {
        get {
            guard let gamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue) as Int? else {
                return 0
            }
            return gamesCount
        }

        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        if bestGame < currentGame { bestGame = currentGame }
        gamesCount += 1

        let сurrentAccuracy = Double(count) / Double(amount) * 100
        let savingTotalAccurancy = totalAccuracy * (Double(gamesCount) - 1)
        let setAccuracy = (сurrentAccuracy + savingTotalAccurancy) / Double(gamesCount)
        userDefaults.set(setAccuracy, forKey: Keys.total.rawValue)
    }
}
