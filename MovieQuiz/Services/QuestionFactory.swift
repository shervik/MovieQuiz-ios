//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 31.10.2022.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
}

final class QuestionFactory: QuestionFactoryProtocol {
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private let networkClient = NetworkClient()
    private var movies: [MostPopularMovie] = []

    //    private let questions: [QuizQuestion] = [
    //        QuizQuestion(image: "The Godfather", text: questionQuiz, correctAnswer: true),
    //        QuizQuestion(image: "The Dark Knight", text: questionQuiz, correctAnswer: true),
    //        QuizQuestion(image: "Kill Bill", text: questionQuiz, correctAnswer: true),
    //        QuizQuestion(image: "The Avengers", text: questionQuiz, correctAnswer: true),
    //        QuizQuestion(image: "Deadpool", text: questionQuiz, correctAnswer: true),
    //        QuizQuestion(image: "The Green Knight", text: questionQuiz, correctAnswer: true),
    //        QuizQuestion(image: "Old", text: questionQuiz, correctAnswer: false),
    //        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: questionQuiz, correctAnswer: false),
    //        QuizQuestion(image: "Tesla", text: questionQuiz, correctAnswer: false),
    //        QuizQuestion(image: "Vivarium", text: questionQuiz, correctAnswer: false)
    //    ]

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func loadData() {
        moviesLoader.loadMovies { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        let index = (0..<movies.count).randomElement() ?? 0
        let quizRating = Float.random(in: 5.0...9.0)
        let arrayRange = ["больше", "меньше"].randomElement() ?? "больше"
        guard let movie = movies[safe: index] else { return }
        let text = "Рейтинг этого фильма \(arrayRange) чем \(String(format: "%.0f", quizRating))?"
        let rating = Float(movie.rating) ?? 0

        let correctAnswer: Bool = {
            if arrayRange == "больше" {
                return rating > Float(quizRating)
            } else {
                return rating < Float(quizRating)
            }
        }()

        networkClient.fetch(url: movie.resizedImageURL) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                switch result {
                case .success(let imageData):
                    let question = QuizQuestion(
                        image: imageData,
                        text: text,
                        correctAnswer: correctAnswer)

                    self.delegate?.didRecieveNextQuestion(question: question)
                case .failure(let failure):
                    self.delegate?.didFailToLoadData(with: failure)
                }
            }
        }
    }
}
