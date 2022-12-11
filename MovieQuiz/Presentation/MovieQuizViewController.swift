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

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private var safeArea: UILayoutGuide { view.safeAreaLayoutGuide }

    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter?

    private let questionTitleLabel = UILabel()
    private let indexLabel = UILabel()
    private let previewImage = UIImageView()
    private let parentView = UIView()
    private let questionLabel = UILabel()
    private let yesButton = UIButton(type: .system)
    private let noButton = UIButton(type: .system)
    private var activityIndicator = UIActivityIndicatorView(style: .large)

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
        [labelStackView, previewImage, activityIndicator, parentView, buttonStackView].forEach { view in
            stackView.addArrangedSubview(view)
        }
        return stackView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        presenter?.viewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypBlack
        configureMainView()
        configureLabel()
        configureImage()
        configureQuestionLabel()
        configureButton()
        configureIndicator()
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
        indexLabel.accessibilityIdentifier = "Index"
    }

    private func configureImage() {
        previewImage.widthAnchor.constraint(
            equalTo: previewImage.heightAnchor, multiplier: 2 / 3
        ).isActive = true
        previewImage.contentMode = .scaleAspectFill
        previewImage.backgroundColor = .ypWhite
        previewImage.layer.cornerRadius = Constants.cornerRadius
        previewImage.accessibilityIdentifier = "Poster"
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
        yesButton.accessibilityIdentifier = "Yes"
        noButton.accessibilityIdentifier = "No"

        yesButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }

    private func configureIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.leadingAnchor.constraint(
            equalTo: safeArea.leadingAnchor, constant: Constants.anchorHorizontal
        ).isActive = true
        activityIndicator.trailingAnchor.constraint(
            equalTo: safeArea.trailingAnchor, constant: -Constants.anchorHorizontal
        ).isActive = true
        activityIndicator.topAnchor.constraint(
            equalTo: safeArea.topAnchor, constant: Constants.anchorTop
        ).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }

    // MARK: - Actions

    @objc private func buttonClicked(_ sender: UIButton) {
        if sender == yesButton { presenter?.yesButtonClicked() }
        if sender == noButton { presenter?.noButtonClicked() }

        sender.backgroundColor = .gray
        [yesButton, noButton].forEach { button in
            button.isEnabled = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            [self.yesButton, self.noButton].forEach { button in
                button.isEnabled = true
            }
            sender.backgroundColor = .ypWhite
        }
    }

    // MARK: - Other functions

    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func show(quiz step: QuizStepViewModel) {
        previewImage.layer.borderColor = UIColor.clear.cgColor
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResultsViewModel) {
        let quizAlert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                self.presenter?.restartGame()
        }

        alertPresenter?.showAlert(alert: quizAlert)
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let errorAlert = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                self.showLoadingIndicator()
                self.presenter?.willRequestNextQuestion()
        }

        alertPresenter?.showAlert(alert: errorAlert)
    }
}
