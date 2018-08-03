//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/13/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import UIKit


class PhotosCollectionViewCell: UICollectionViewCell  {
    @IBOutlet weak var collectionImage: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Alpha setting based on selected status
    override var isSelected: Bool {
        didSet {
            alpha = isSelected ? 0.5 : 1.0
        }
    }
    
    // MARK: Cell Configuration
    func configureCell(image: Data?) {
        if let imageData = image {
            activityIndicatorView.stopAnimating()
            collectionImage.image = UIImage(data: imageData)
        } else {
            collectionImage.image = nil
            backgroundColor = UIColor.gray
            activityIndicatorView.startAnimating()
        }
    }
}
