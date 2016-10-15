//
//  MovieCollectionViewCell.swift
//  Flick
//
//  Created by Liem Ly Quan on 10/15/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    
    var movie:NSDictionary! {
        didSet {
            if let posterPath = movie["poster_path"] as? String {
                let lowImageQualityUrl = URL(string: "\(GlobalConstants.lowQualityImageBaseUrl)\(posterPath)")
                let highImageQualityUrl = URL(string: "\(GlobalConstants.highQualityImageBaseUrl)\(posterPath)")
                if let lowImageQualityUrl = lowImageQualityUrl {
                    posterImageView.af_setImage(withURL: lowImageQualityUrl, imageTransition: .crossDissolve(0.5), completion: { response in
                        // TODO: find some way to do it in cleaner way
                        if let highImageQualityUrl = highImageQualityUrl {
                            self.posterImageView.af_setImage(withURL: highImageQualityUrl, imageTransition: .crossDissolve(0.5))
                        }
                    })
                }
            }
        }
    }
}
