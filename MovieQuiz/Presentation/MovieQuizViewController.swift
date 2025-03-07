import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Outlet

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties

    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    // общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    // фабрика вопросов. Контроллер будет обращаться за вопросами к ней.
    private var questionFactory: QuestionFactoryProtocol?
    // вопрос, который видит пользователь.
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        editedImage()

        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(
            delegate: self,
            moviesLoader: MoviesLoader()
        )

        guard let questionFactory = questionFactory else { return }
        questionFactory.loadData()

        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()

    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {

        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.show(quiz: viewModel)
        }
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - IB Actions

    @IBAction private func yesButtonClicked(_ sender: Any) {

        changeStateButtons(isEnabled: false)
        guard let currentQuestion else { return }

        let givenAnswer = true

        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {

        changeStateButtons(isEnabled: false)
        guard let currentQuestion else { return }

        let givenAnswer = false

        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    // MARK: - Private Methods

    // принимает моковый вопрос и возвращает вью модель для вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        self.imageView.layer.borderColor = UIColor.clear.cgColor
    }

    // Статистика игры, выходит в алерте
    private func getGamesStatistic(correct count: Int, total amount: Int) -> String {

        guard let statisticService = statisticService else {
            return "Ваш результат: \(count)/\(amount)"
        }

        let score = "Ваш результат: \(count)/\(amount)"
        let gamesCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let record = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let totalAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        return [score, gamesCount, record, totalAccuracy].joined(separator: "\n")
    }

    // показать результат
    private func show(_ result: QuizResultsViewModel) {

        let statisticText = getGamesStatistic(
            correct: correctAnswers,
            total: questionsAmount
        )

        let alertModel = AlertModel(
            title: result.title,
            message: statisticText,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.showAlert(with: alertModel)
    }

    //  меняем цвет рамки
    private func showAnswerResult(isCorrect: Bool) {

        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            self.showNextQuestionOrResults()
            self.changeStateButtons(isEnabled: true)
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }

    // показать следующий вопрос или результат
    private func showNextQuestionOrResults() {

        if currentQuestionIndex == questionsAmount - 1 {

            guard let statisticService = statisticService else { return }
            statisticService
                .store(correct: correctAnswers, total: questionsAmount)

            let message = getGamesStatistic(
                correct: correctAnswers,
                total: questionsAmount
            )

            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    guard let questionFactory = self?.questionFactory else {return}
                    questionFactory.requestNextQuestion()
            }
            )
            guard let alertPresenter else { return }
            alertPresenter.showAlert(with: alertModel)
        } else {
            currentQuestionIndex += 1
            guard let questionFactory = questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
    }

    // блокировка кнопок
    private func changeStateButtons(isEnabled: Bool) {

        yesButton.isEnabled = isEnabled
        yesButton.alpha = isEnabled ? 1.0 : 0.5

        noButton.isEnabled = isEnabled
        noButton.alpha = isEnabled ? 1.0 : 0.5
    }

    // картинка при загрузки
    private func editedImage() {
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20

        textLabel.text = ""
        counterLabel.text = ""
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        alertPresenter?.closeAlert()
        questionFactory?.requestNextQuestion()
    }

    // отображение индикатора
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    // скрытие индикатора
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }

                self.questionFactory?.loadData()
            }

        alertPresenter?.showAlert(with: model)
    }
}
