//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 08.12.2022.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    weak var viewController: MovieQuizViewControllerProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    // MARK: - QuestionFactoryDelegate

    func didRecieveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()

        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        willRequestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    // MARK: - Actions

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        willRequestNextQuestion()
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func willRequestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }

    // MARK: - Private functions

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func didAnswer(_ isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1 }
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }

            self.viewController?.showLoadingIndicator()
            self.proceedToNextQuestionOrResults()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: results)
        } else {
            switchToNextQuestion()
            willRequestNextQuestion()
        }
    }

    func makeResultsMessage() -> String {
        if let statisticService = statisticService {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService.bestGame

            let statisticText = """
    Ваш результат: \(correctAnswers)/\(questionsAmount)
    Количество сыгранных квизов: \(statisticService.gamesCount)
    Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
    """

            return statisticText
        }
        return ""
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
