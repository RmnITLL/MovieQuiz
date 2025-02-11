//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by R Kolos on 04.02.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
