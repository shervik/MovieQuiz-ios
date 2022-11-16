import UIKit

private enum Constants {
    static let anchorHorizontal: CGFloat = 20
    static let anchorTop: CGFloat = 10
    static let anchorLabelHorisontal: CGFloat = 42
    static let anchorLabelVertical: CGFloat = 13
    static let spacing: CGFloat = 20
    static let heightButton: CGFloat = 60
    static let cornerRadius: CGFloat = 15
}

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var safeArea: UILayoutGuide { view.safeAreaLayoutGuide }

    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceImplementation?

    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0

    private let questionTitleLabel = UILabel()
    private let indexLabel = UILabel()
    private let previewImage = UIImageView()
    private let parentView = UIView()
    private let questionLabel = UILabel()
    private let yesButton = UIButton(type: .system)
    private let noButton = UIButton(type: .system)

    private lazy var labelStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubview(questionTitleLabel)
        stackView.addArrangedSubview(indexLabel)
        return stackView
    }()

    private lazy var buttonStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.spacing
        stackView.distribution = .fillEqually
        stackView.heightAnchor.constraint(equalToConstant: Constants.heightButton).isActive = true
        stackView.addArrangedSubview(noButton)
        stackView.addArrangedSubview(yesButton)
        return stackView
    }()

    private lazy var mainStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.addArrangedSubview(labelStackView)
        stackView.addArrangedSubview(previewImage)
        stackView.addArrangedSubview(parentView)
        stackView.addArrangedSubview(buttonStackView)
        return stackView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypBlack
        configureMainView()
        configureLabel()
        configureImage()
        configureQuestionLabel()
        configureButton()
    }

    // MARK: - QuestionFactoryDelegate

    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    // MARK: - Configuration views

    private func configureMainView() {
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.leadingAnchor.constraint(
            equalTo: safeArea.leadingAnchor, constant: Constants.anchorHorizontal
        ).isActive = true
        mainStackView.trailingAnchor.constraint(
            equalTo: safeArea.trailingAnchor, constant: -Constants.anchorHorizontal
        ).isActive = true
        mainStackView.topAnchor.constraint(
            equalTo: safeArea.topAnchor, constant: Constants.anchorTop
        ).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }

    private func configureLabel() {
        questionTitleLabel.textAlignment = .left
        questionTitleLabel.text = "Вопрос:"
        questionTitleLabel.textColor = .ypWhite
        questionTitleLabel.font = UIFont.ysDisplayMedium

        indexLabel.textAlignment = .right
        indexLabel.textColor = .ypWhite
        indexLabel.font = UIFont.ysDisplayMedium
        indexLabel.setContentHuggingPriority(UILayoutPriority(252), for: .horizontal)
    }

    private func configureImage() {
        previewImage.widthAnchor.constraint(
            equalTo: previewImage.heightAnchor, multiplier: 2 / 3
        ).isActive = true
        previewImage.contentMode = .scaleAspectFill
        previewImage.backgroundColor = .ypWhite
        previewImage.layer.masksToBounds = true
        previewImage.layer.cornerRadius = Constants.cornerRadius
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = UIColor.clear.cgColor
    }

    private func configureQuestionLabel() {
        parentView.addSubview(questionLabel)
        parentView.contentMode = .scaleAspectFill

        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.leadingAnchor.constraint(
            equalTo: parentView.leadingAnchor, constant: Constants.anchorLabelHorisontal
        ).isActive = true
        questionLabel.trailingAnchor.constraint(
            equalTo: parentView.trailingAnchor, constant: -Constants.anchorLabelHorisontal
        ).isActive = true
        questionLabel.topAnchor.constraint(
            equalTo: parentView.topAnchor, constant: Constants.anchorLabelVertical
        ).isActive = true
        questionLabel.bottomAnchor.constraint(
            equalTo: parentView.bottomAnchor, constant: -Constants.anchorLabelVertical
        ).isActive = true
        questionLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
        questionLabel.textAlignment = .center
        questionLabel.textColor = .ypWhite
        questionLabel.font = UIFont.ysDisplayBold
        questionLabel.numberOfLines = 2
    }

    private func configureButton() {
        let arrayButton = [yesButton, noButton]
        arrayButton.forEach {
            $0.setTitleColor(.ypBlack, for: .normal)
            $0.backgroundColor = .ypWhite
            $0.titleLabel?.font = UIFont.ysDisplayMedium
            $0.layer.cornerRadius = Constants.cornerRadius
        }
        yesButton.setTitle("Да", for: .normal)
        noButton.setTitle("Нет", for: .normal)

        yesButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func buttonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        var givenAnswer = true
        sender.isEnabled = false
        sender.backgroundColor = .gray

        if sender == yesButton {
            self.noButton.isEnabled = false
        } else {
            givenAnswer = false
            self.yesButton.isEnabled = false
        }

        self.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {[weak self] _ in
            guard let self = self else { return }

            sender.isEnabled = true
            sender.backgroundColor = .ypWhite

            if sender == self.yesButton {
                self.noButton.isEnabled = true
            } else {
                self.yesButton.isEnabled = true
            }
        }
    }

    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        if isCorrect { correctAnswers += 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }

            self.showNextQuestionOrResults()
            self.previewImage.layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func show(quiz step: QuizStepViewModel) {
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
    }

    private func show(quiz result: QuizResultsViewModel) {
        let quizAlert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
        }

        alertPresenter?.showAlert(alert: quizAlert)
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService.bestGame
            let statisticText = """
    Ваш результат: \(correctAnswers)/\(questionsAmount)
    Количество сыгранных квизов: \(statisticService.gamesCount)
    Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
    """

            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: statisticText,
                buttonText: "Сыграть еще раз")

            show(quiz: results)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    // MARK: - Private functions

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func jsonToMovie() {
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        documentsURL?.appendPathComponent("top250MoviesIMDB.json")
        guard let documentsURL = documentsURL else { return }
        let jsonString = try? String(contentsOf: documentsURL)

        do {
            guard let data = jsonString?.data(using: .utf8) else { return }
            let movie = try JSONDecoder().decode(ItemsMovie.self, from: data)

            print(movie)
        } catch {
            print("Failed to parse: \(String(describing: jsonString))")
        }
    }
}
