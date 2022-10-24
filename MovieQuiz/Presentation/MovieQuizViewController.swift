import UIKit

private enum Constants {
    static let anchorHorizontal: CGFloat = 20
    static let anchorTop: CGFloat = 10
    static let anchorLabelHorisontal: CGFloat = 42
    static let anchorLabelVertical: CGFloat = 13
    static let spacing: CGFloat = 20
    static let heightButton: CGFloat = 60
    static let cornerRadius: CGFloat = 15
    static let questionQuiz: String = "Рейтинг этого фильма больше чем 6?"
}

// для состояния "Вопрос задан"
struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// для состояния "Результат квиза"
struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

// для состояния "Результат ответа"
struct QuizResponseViewModel {
    let isTrue: Bool
}

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

final class MovieQuizViewController: UIViewController {
    private var safeArea: UILayoutGuide { view.safeAreaLayoutGuide }

    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: Constants.questionQuiz, correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: Constants.questionQuiz, correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: Constants.questionQuiz, correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: Constants.questionQuiz, correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: Constants.questionQuiz, correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: Constants.questionQuiz, correctAnswer: true),
        QuizQuestion(image: "Old", text: Constants.questionQuiz, correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: Constants.questionQuiz, correctAnswer: false),
        QuizQuestion(image: "Tesla", text: Constants.questionQuiz, correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: Constants.questionQuiz, correctAnswer: false)
    ]

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

    private var currentQuestionIndex: Int = 0
    private lazy var currentQuestion = questions[currentQuestionIndex]
    private var correctAnswers: Int = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainView()
        configureLabel()
        configureImage()
        configureQuestionLabel()
        configureButton()
        show(quiz: convert(model: currentQuestion))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypBlack
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
        let currentQuestion = questions[currentQuestionIndex]
        var givenAnswer = true
        sender.isUserInteractionEnabled = false
        sender.backgroundColor = .gray

        if sender == yesButton {
            self.noButton.isUserInteractionEnabled = false
        } else {
            givenAnswer = false
            self.yesButton.isUserInteractionEnabled = false
        }

        self.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            sender.isUserInteractionEnabled = true
            sender.backgroundColor = .ypWhite

            if sender == self.yesButton {
                self.noButton.isUserInteractionEnabled = true
            } else {
                self.yesButton.isUserInteractionEnabled = true
            }
        }
    }

    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        if isCorrect { correctAnswers += 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            self.show(quiz: self.convert(model: firstQuestion))
        }

        alert.addAction(action)
        self.present(alert, animated: true)
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let results = QuizResultsViewModel(
                title: "Раунд окончен!", text: "Ваш результат: \(correctAnswers)", buttonText: "Сыграть еще раз"
            )
            show(quiz: results)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            show(quiz: convert(model: nextQuestion))
        }
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
}
