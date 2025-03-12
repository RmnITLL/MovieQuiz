//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by R Kolos on 04.02.2025.
//

import UIKit

final class AlertPresenter {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showAlert(with model: AlertModel) {

        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }

        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)

#if DEBUG
        alert.view.accessibilityIdentifier = "AlertPresenter"
#endif
    }


    // при ошибке скрывается алерт
 //   func closeAlert() {
 //       viewController?.dismiss(animated: true, completion: nil)
 //   }
}
