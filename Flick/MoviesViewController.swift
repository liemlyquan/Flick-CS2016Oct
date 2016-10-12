//
//  MoviesViewController.swift
//  Flick
//
//  Created by Liem Ly Quan on 10/10/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ARSLineProgress


class MoviesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let lowQualityImageBaseUrl = "https://image.tmdb.org/t/p/w45"
    let highQualityImageBaseUrl  = "https://image.tmdb.org/t/p/original"
    var movies:[NSDictionary] =  []
    var filteredMovies:[NSDictionary] = []
    var endpoint = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        initDelegate()
        
        searchBar.delegate = self
        
        loadMovie()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()

    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initDelegate(){
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        //        collectionView.delegate = self
        //        collectionView.dataSource = self
    }
    
    func initUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        segmentedControl.frame.size.height = searchBar.frame.height
    }
    
    func loadMovie(){
        let url = "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)"
        Alamofire
        .request(url)
        .validate()
        .responseJSON { response in
            switch response.result {
                case .success(_):
                    if let data = response.data {
                        if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            if let results = responseDictionary["results"] as? [NSDictionary] {
                                self.movies = results
                                self.filteredMovies = self.movies
                                self.tableView.reloadData()
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    // MARK: Only print message "defined" error
                    if let statusCode = response.response?.statusCode {
                        if (400...499 ~=  statusCode){
                            if let data = response.data {
                                if let errorDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                    if let errorMessage = errorDictionary["status_message"] as? String {
                                        print(errorMessage)
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender = sender as? MovieTableViewCell {
            guard let indexPath = tableView.indexPath(for: sender) else {
                return
            }
            let movie = movies[indexPath.row]
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.movie = movie
            }
        }
    }
}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        let movie = filteredMovies[indexPath.row]
        // MARK: Since every movie has title and overview, it should be safe to group them together
        if let title = movie["title"] as? String, let overview = movie["overview"] as? String {
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
        }
        if let posterPath = movie["poster_path"] as? String {
            let lowImageQualityUrl = URL(string: "\(lowQualityImageBaseUrl)\(posterPath)")
            let highImageQualityUrl = URL(string: "\(highQualityImageBaseUrl)\(posterPath)")
            if let lowImageQualityUrl = lowImageQualityUrl {
                cell.posterImageView.af_setImage(withURL: lowImageQualityUrl, completion: { response in
                    // TODO: find some way to do it in cleaner way
                    if let highImageQualityUrl = highImageQualityUrl {
                        cell.posterImageView.af_setImage(withURL: highImageQualityUrl)
                    }
                })
            }
        }
        
        return cell
    }
}

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies.filter({
                if let title = $0["title"] as? String, let overview = $0["overview"] as? String {
                    return title.range(of: searchText, options: .caseInsensitive) != nil
                        || overview.range(of: searchText, options: .caseInsensitive) != nil
                }
                return false
            })
        }
        tableView.reloadData()
    }
}
