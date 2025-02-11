import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    /*
     За создание и хранение моделей QuizQuestion.
     Создание QuizStepViewModel.
     Обновление состояния текстов и картинок с помощью ViewModel.
     Решение отобразить алерт о результатах игры или следующий вопрос.
     */

    // MARK: - Outlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

        // MARK: - Private Properties

    private var currentQuestionIndex = 0
    private var correctAnswers = 0

        // общее количество вопросов для квиза
    private let questionsAmount: Int = 10
        // фабрика вопросов. Контроллер будет обращаться за вопросами к ней.
    private var questionFactory: QuestionFactoryProtocol?
        // вопрос, который видит пользователь.
    private var currentQuestion: QuizQuestion?

        // + добавили
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?



        // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

            //        let questionFactory = QuestionFactory()
            //        questionFactory.setup(delegate: self)
            //        self.questionFactory = questionFactory
            //
            //        questionFactory.requestNextQuestion()
            //       // print(Bundle.main.bundlePath)
            //        print(NSHomeDirectory())

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8

        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()

        questionFactory = QuestionFactory(delegate: self)
        guard let questionFactory = questionFactory else { return }
        questionFactory.requestNextQuestion()

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
            self?.show(quiz: viewModel)
        }
    }



    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {

       // changeStateButtons(isEnabled: false)
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = true

        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
       // changeStateButtons(isEnabled: false)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {

      //  changeStateButtons(isEnabled: false)

        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = false

        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
       // changeStateButtons(isEnabled: false)
    }



    // MARK: - Private Methods

    // принимает моковый вопрос и возвращает вью модель для вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }

    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    private func show(quiz step: QuizStepViewModel) {

        imageView.image = step.image
            //imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

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

    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
        // showResult
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
                self?.restartQuiz()
            }
        )
        alertPresenter?.showAlert(with: alertModel)
    }


//    private func show(quiz result: QuizResultsViewModel) {
//        let alert = UIAlertController(
//            title: result.title,
//            message: result.text,
//            preferredStyle: .alert)
//
//        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
//            guard let self = self else { return }
//
//            self.restartQuiz()
//
////            self.currentQuestionIndex = 0
////            self.correctAnswers = 0
////            self.questionFactory?.requestNextQuestion()
////
////            if let firstQuestion = self.questionFactory?.requestNextQuestion() {
////                self.currentQuestion = firstQuestion
////
////                let viewModel = self.convert(model: firstQuestion)
////
////                self.show(quiz: viewModel)
////            }
//
//        }
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
//    }


    //  меняем цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

//        imageView.layer.masksToBounds = true
//        imageView.layer.borderWidth = 8
//        imageView.layer.borderColor = UIColor.white.cgColor
//        imageView.layer.cornerRadius = 20

        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
         //   self.yesButton.isEnabled = true
          //  self.noButton.isEnabled = true
            self.changeStateButtons(isEnabled: true)
        }
    }

    // логика перехода в один из сценариев
    private func showNextQuestionOrResults() {

       // changeStateButtons(isEnabled: true)

        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            statisticService?
                .store(correct: correctAnswers, total: questionsAmount)
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            // showResults
            show(viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }

    private func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = true
        noButton.isEnabled = true

         noButton.alpha = isEnabled ? 1.0 : 0.5
         yesButton.alpha = isEnabled ? 1.0 : 0.5
    }

}
