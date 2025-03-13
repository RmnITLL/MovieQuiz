//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by R Kolos on 11.03.2025.
//

import XCTest
import Foundation

@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {

    func show(quiz step: QuizStepViewModel) {

    }

    func highlightImageBorder(isCorrectAnswer: Bool) {

    }

    func showLoadingIndicator() {

    }

    func hideLoadingIndicator() {

    }


    func showNetworkError(message: String) {

    }

    func editImageBorder() {

    }

    func showAlert(with model: MovieQuiz.AlertModel) {

    }

    func changeStateButtons(isEnabled: Bool) {

    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(
            imageName: emptyData,
            text: "Question Text",
            correctAnswer: true
        )
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
