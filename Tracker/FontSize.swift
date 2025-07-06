//
//  FontSize.swift
//  Tracker
//
//  Created by Ди Di on 11/06/25.
//

import UIKit


enum FontSize {
    static let size10: CGFloat = 10
    static let size12: CGFloat = 12
    static let size16: CGFloat = 16
    static let size17: CGFloat = 17
    static let size19: CGFloat = 19
    static let size32: CGFloat = 32
    static let size34: CGFloat = 34
}

extension UIFont {
    static let sfProDisplayMedium10 = UIFont(name: "SFProDisplay-Medium", size: FontSize.size10)
    static let sfProDisplayMedium12 = UIFont(name: "SFProDisplay-Medium", size: FontSize.size12)
    static let sfProDisplayMedium16 = UIFont(name: "SFProDisplay-Medium", size: FontSize.size16)
    static let sfProDisplayRegular17 = UIFont(name: "SFProDisplay-Regular", size: FontSize.size17)
    static let sfProDisplayBold19 = UIFont(name: "SFProDisplay-Bold", size: FontSize.size17)
    static let sfProDisplayBold32 = UIFont(name: "SFProDisplay-Bold", size: FontSize.size32)
    static let sfProDisplayBold34 = UIFont(name: "SFProDisplay-Bold", size: FontSize.size34)
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
