//
//  DetailViewController.swift
//  Flick
//
//  Created by Liem Ly Quan on 10/11/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit
import AlamofireImage

class DetailViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    var movie:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData() {
        guard let title = movie["title"] as? String,
            let overview = movie["overview"] as? String else {
                // TODO: maybe display some error message her
                return
        }
        titleLabel.text = title
        overviewLabel.text = overview
        
        // MARK: since there maybe cases of movie without poster, so unwrap it seperately
        guard let posterPath = movie["poster_path"] as? String else {
            return
        }
        let baseURL = "https://image.tmdb.org/t/p/original"
        if let posterURL = URL(string: "\(baseURL)\(posterPath)") {
            posterImageView.af_setImage(withURL: posterURL)
        }
        

    }
}
