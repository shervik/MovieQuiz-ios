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
    private enum RatingConstants {
        static let moreRatingText = "больше"
        static let lessRatingText = "меньше"
    }

    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private let networkClient: NetworkRouting
    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
        networkClient = NetworkClient()
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
        guard let movie = movies[safe: index] else { return }

        let quizRating = Float.random(in: 5.0...9.0)
        let arrayRange = [RatingConstants.moreRatingText, RatingConstants.lessRatingText]
            .randomElement() ?? RatingConstants.moreRatingText

        let text = "Рейтинг этого фильма \(arrayRange) чем \(String(format: "%.0f", quizRating))?"
        let rating = Float(movie.rating) ?? 0

        let correctAnswer: Bool = {
            if arrayRange == RatingConstants.moreRatingText {
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
