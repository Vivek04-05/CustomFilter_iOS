//
//  Extension.swift
//  FilterColor
//
//  Created by Vivek Patel on 08/07/24.
//

import UIKit

extension UIView {
    
    func animate() {
        UIView.animate(withDuration: 0.2, animations: { self.transform = CGAffineTransform(scaleX: 0.978, y: 0.98)},completion: { finish in
            UIView.animate(withDuration: 0.2, animations: { self.transform = CGAffineTransform.identity})
        })
    }
}
