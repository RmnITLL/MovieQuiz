//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by R Kolos on 26.02.2025.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
