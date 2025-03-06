//
//  UIViewController+Extension.swift
//  NBCampStart
//
//  Created by 서동환 on 3/6/25.
//

import UIKit

extension UIViewController {
    func screen() -> UIScreen? {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            // 대안 1
            return view.window?.windowScene?.screen
        }
        
        // 대안 2
        return window.screen
    }
}
