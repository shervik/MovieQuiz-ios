//
//  UIFont+Extensions.swift
//  MovieQuiz
//
//  Created by Виктория Щербакова on 22.10.2022.
//

import Foundation
import UIKit

extension UIFont {
    static func ysDisplayMedium(size: CGFloat) -> UIFont { UIFont(name: "YSDisplay-Medium", size: size) ?? UIFont() }
    static func ysDisplayBold(size: CGFloat) -> UIFont { UIFont(name: "YSDisplay-Bold", size: size) ?? UIFont() }
}
