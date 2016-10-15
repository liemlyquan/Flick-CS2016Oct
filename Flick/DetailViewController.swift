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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!


    var movie:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI(){
        overviewLabel.sizeToFit()
        // MARK: somehow this feel like another version of auto layout
        infoView.frame.size.height = overviewLabel.frame.maxY + 30
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + infoView.frame.height + 10)
        posterImageView.frame.size.height = scrollView.contentSize.height
        

    }
    
    func initData() {
        guard let title = movie["title"] as? String,
            let overview = movie["overview"] as? String else {
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
