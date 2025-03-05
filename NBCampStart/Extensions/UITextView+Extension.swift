//
//  UITextView+Extension.swift
//  NBCampStart
//
//  Created by 서동환 on 3/5/25.
//

import UIKit

extension UITextView {
    func alignTextVerticallyInContainer() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }
}
