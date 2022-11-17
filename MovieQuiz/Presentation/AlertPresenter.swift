//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 08.11.2022.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func showAlert(alert: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol {
    private weak var viewController: UIViewController?

    init(delegate: UIViewController?) {
        self.viewController = delegate
    }

    func showAlert(alert: AlertModel) {
        let alertContoller = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)

        let action = UIAlertAction(
            title: alert.buttonText,
            style: .default) { _ in
            alert.completion?()
        }

        alertContoller.addAction(action)
        viewController?.present(alertContoller, animated: true)
    }
}
