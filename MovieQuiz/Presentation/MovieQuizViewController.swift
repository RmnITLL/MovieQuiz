import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: - Outlet

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties

    private var presenter: MovieQuizPresenter?

    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        editedImage()

        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()

        presenter = MovieQuizPresenter(viewController: self)

        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()

    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - IB Actions

    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let presenter = presenter else { return }
        presenter.yesButtonClecked()
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let presenter = presenter else { return }
        presenter.noButtonClicked()
    }

    // MARK: - Private Methods

    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        //self.imageView.layer.borderColor = UIColor.clear.cgColor
    }

    // блокировка кнопок
    func changeStateButtons(isEnabled: Bool) {

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

        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    func showAlert(with model: AlertModel) {
        alertPresenter?.showAlert(with: model)
    }

    func editImageBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    // отображение индикатора
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    // скрытие индикатора
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.restartGame()
        }

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
