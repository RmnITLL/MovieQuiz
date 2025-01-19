import UIKit

final class MovieQuizViewController: UIViewController {
        //        // MARK: - Lifecycle
        //    override func viewDidLoad() {
        //        super.viewDidLoad()
        //    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!

    @IBOutlet weak var counterLabel: UILabel!


    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true

        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false

        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }

        // переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0

        // переменная правильных ответов
    private var correctAnswers = 0

        // текущий вопрос из массива по индексу текущего массива вопроса
        //let currentQuestion = questions[currentQuestionIndex]

    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }

        // структура вопроса
    struct QuizQuestion {
            // строка с названием фильма
            // совпадает с названием картинки афиши фильма в Assets
        let image: String

            // строка с вопросом о рейтинге фильма
        let text: String

            // булевое значение (true, false), правильный ответ на вопрос
        let correctAnswer: Bool

    }

        // вью модель для состояния "Вопрос показан"
    struct QuizStepViewModel {
            // картинка с афишей фильма с типом UIImage
        let image: UIImage

            // вопрос о рейтинге квиза
        let question: String

            // строка с порядковым номером этого вопроса (ex. "1/10")
        let questionnumber: String
    }

        // массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]

        // метод конвертации, который принимает моковый вопрос и возвращает вью модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionnumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }

        // метод вывода на экран вопроса, который принимает вью модель ворпоса и ничего не вывыдит
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionnumber
    }

        // метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

            // запускаем задачу через 1 секунду с помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuiestionOrResults()
        }

    }

        // метод, который содержит логику перехода в один из сценариев
    private func showNextQuiestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
                // идем в состояние "Результат квиза"
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
                // идем в состояние "Вопрос показан"

            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)

            show(quiz: viewModel)
        }
    }

    // метод для показа результатов раунда квиза
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)

    }






    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //show(quiz: viewMo)
    }

}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
