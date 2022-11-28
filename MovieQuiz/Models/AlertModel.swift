//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 08.11.2022.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: (() -> Void)?
}
