//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by R Kolos on 01.02.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {

    func didReceiveNextQuestion(question: QuizQuestion?)
}
