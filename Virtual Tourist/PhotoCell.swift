//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Che-Chuen Ho on 7/1/15.
//  Copyright (c) 2015 Che-Chuen Ho. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    func setPhoto(image: UIImage?, hidden: Bool) {
        self.photoView.image = image
        self.photoView.hidden = hidden
    }
    
    func setLoadingIndicator(animating: Bool) {
        if animating {
            self.spinnerView.startAnimating()
        } else {
            self.spinnerView.stopAnimating()
        }
    }
    
}