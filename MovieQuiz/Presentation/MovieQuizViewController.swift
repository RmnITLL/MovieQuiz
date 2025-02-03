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


    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {

        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = true

        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }

    @IBAction private func noButtonClicked(_ sender: Any) {

        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = false

        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }

    // MARK: - Private Properties

    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    // общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    // фабрика вопросов. Контроллер будет обращаться за вопросами к ней.
    private var questionFactory: QuestionFactoryProtocol?
    // вопрос, который видит пользователь.
    private var currentQuestion: QuizQuestion?

    


        // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory

        questionFactory.requestNextQuestion()
       // print(Bundle.main.bundlePath)
        print(NSHomeDirectory())
    }

//        if let firstQuestion = questionFactory.requestNextQuestion() {
//            currentQuestion = firstQuestion
//            let viewModel = convert(model: firstQuestion)
//
//            show(quiz: viewModel)
      //  }
    //}

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



    // MARK: - Private Methods

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

    }

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            self.questionFactory?.requestNextQuestion()

//            if let firstQuestion = self.questionFactory.requestNextQuestion() {
//                self.currentQuestion = firstQuestion
//                let viewModel = self.convert(model: firstQuestion)
//
//                self.show(quiz: viewModel)

         //   }
        }

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }


    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {

        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()

//            if let nextQuestion = questionFactory.requestNextQuestion() {
//                currentQuestion = nextQuestion
//                let viewModel = convert(model: nextQuestion)
//
//                imageView.layer.borderWidth = 0
//                show(quiz: viewModel)
//            }
        }
    }

}
