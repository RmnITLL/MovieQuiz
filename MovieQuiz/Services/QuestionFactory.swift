    //
    //  QuestionFactory.swift
    //  MovieQuiz
    //
    //  Created by R Kolos on 28.01.2025.
    //
    //  храниться массив с вопросами и один метод, который вернёт случайно выбранный вопрос.

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {


    // MARK: - Private Properties

    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private weak var delegate: QuestionFactoryDelegate?

    init(delegate: QuestionFactoryDelegate, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }


    /*
     private let questions: [QuizQuestion] = [
     QuizQuestion(imageName: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
     QuizQuestion(imageName: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
     QuizQuestion(imageName: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
     QuizQuestion(imageName: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
     QuizQuestion(imageName: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
     QuizQuestion(imageName: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
     QuizQuestion(imageName: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
     QuizQuestion(imageName: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
     QuizQuestion(imageName: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
     QuizQuestion(imageName: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
     ]
     */

        // MARK: - Methods

        // случайный вопрос
    func requestNextQuestion() {

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }
            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?
                    .didFailToLoadData(
                        with: NSError(
                            domain: "com.moviequiz",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Невозможно загрузить данные"]
                        )
                    )
            }
            return
        }

        let text = "Рейтинг этого фильма больше чем 9?"
        let rating = Float(movie.rating) ?? 0
        let correctAnswer = rating > 9
        let question = QuizQuestion(
            imageName: imageData,
            text: text,
            correctAnswer: correctAnswer)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.didReceiveNextQuestion(question: question)
        }
    }
}

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                    case .success(let mostPopularMovies):

                        if !mostPopularMovies.errorMessage.isEmpty || mostPopularMovies.items.isEmpty {
                            let errorMessage = mostPopularMovies.errorMessage.isEmpty ? "Нет доступных фильмов." : mostPopularMovies.errorMessage
                            self.delegate?
                                .didFailToLoadData(
                                    with:NSError(
                                        domain: "com.moviequiz",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: errorMessage]
                                    )
                                )
                        } else {
                            self.delegate?.didLoadDataFromServer()
                            self.movies = mostPopularMovies.items
                        }
                    case .failure(let error): self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
