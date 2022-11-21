//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 31.10.2022.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
}

final class QuestionFactory: QuestionFactoryProtocol {
    private static let questionQuiz: String = "Рейтинг этого фильма больше чем 6?"
    private weak var delegate: QuestionFactoryDelegate?

    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: questionQuiz, correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: questionQuiz, correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: questionQuiz, correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: questionQuiz, correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: questionQuiz, correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: questionQuiz, correctAnswer: true),
        QuizQuestion(image: "Old", text: questionQuiz, correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: questionQuiz, correctAnswer: false),
        QuizQuestion(image: "Tesla", text: questionQuiz, correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: questionQuiz, correctAnswer: false)
    ]

    init(delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
    }

    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didRecieveNextQuestion(question: nil)
            return
        }
        delegate?.didRecieveNextQuestion(question: questions[safe: index])
    }
}
