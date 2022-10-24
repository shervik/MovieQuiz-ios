//
//  UIFont+Extensions.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 22.10.2022.
//

import Foundation
import UIKit

extension UIFont {
    static let ysDisplayMedium = UIFont(name: "YSDisplay-Medium", size: 20) ??
    UIFont.systemFont(ofSize: 20, weight: Weight(500))
    static let ysDisplayBold = UIFont(name: "YSDisplay-Bold", size: 23) ??
    UIFont.systemFont(ofSize: 23, weight: Weight(700))
}
