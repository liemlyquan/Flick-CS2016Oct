//
//  MovieTableViewCell.swift
//  Flick
//
//  Created by Liem Ly Quan on 10/10/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!

    var movie:NSDictionary! {
        didSet {
            // MARK: Since every movie has title and overview, it should be safe to group them together
            if let title = movie["title"] as? String, let overview = movie["overview"] as? String {
                titleLabel.text = title
                overviewLabel.text = overview
            }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
