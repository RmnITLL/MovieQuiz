//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by R Kolos on 05.03.2025.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func editImageBorder()
    func showAlert(with model: AlertModel)
    func changeStateButtons(isEnabled: Bool)
}
