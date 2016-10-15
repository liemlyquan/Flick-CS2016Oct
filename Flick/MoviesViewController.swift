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
import SVProgressHUD
import SystemConfiguration
import DZNEmptyDataSet


class MoviesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noNetworkConnectionLabel: UILabel!

    var movies:[NSDictionary] =  []
    var filteredMovies:[NSDictionary] = []
    var endpoint = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initDelegate()
        initRefreshControl()
        initGestureRecognizer()
        loadMovie()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender = sender as? MovieTableViewCell {
            guard let indexPath = tableView.indexPath(for: sender) else {
                return
            }
            let movie = filteredMovies[indexPath.row]
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.movie = movie
            }
        }
        if let sender = sender as? MovieCollectionViewCell {
            guard let indexPath = collectionView.indexPath(for: sender) else {
                return
            }
            let movie = filteredMovies[indexPath.row]
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.movie = movie
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initDelegate(){
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func initRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMovie(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func initUI(){
        navigationItem.titleView = searchBar
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
        self.noNetworkConnectionLabel.layer.zPosition = 1
    }
    
    func initGestureRecognizer(){
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(switchDisplayMode))
        self.view.addGestureRecognizer(pinchGesture)
    }
    
    func loadMovie(_ refreshControl: UIRefreshControl? = nil){
        
        if (connectedToNetwork()){
            let url = "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(GlobalConstants.apiKey)"
            SVProgressHUD.show()
            
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
                                    self.collectionView.reloadData()
                                    refreshControl?.endRefreshing()
                                    SVProgressHUD.showSuccess(withStatus: "Done")
                                }
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        refreshControl?.endRefreshing()
                        SVProgressHUD.showError(withStatus: "Error getting data")
                }
            }
        } else {
            refreshControl?.endRefreshing()
            self.noNetworkConnectionLabel.alpha = 1
            UIView.animate(withDuration: 2, delay: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.noNetworkConnectionLabel.alpha = 0
                }, completion: nil )
        }

    }
    
    func switchDisplayMode(sender: UIPinchGestureRecognizer){
        if (sender.state == .ended){
            let velocity = sender.velocity
            if velocity < 0 {
                collectionView.isHidden = true
                tableView.isHidden = false
            } else if (velocity > 0){
                collectionView.isHidden = false
                tableView.isHidden = true
            }
        }
        
    }
    
    func connectedToNetwork() -> Bool {
        // Thanks to Martin R
        // stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.green
        cell.selectedBackgroundView = backgroundView
        let movie = filteredMovies[indexPath.row]
        cell.movie = movie
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.green
        cell.selectedBackgroundView = backgroundView
        let movie = filteredMovies[indexPath.row]
        cell.movie = movie
        return cell
    }
}

extension MoviesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No results found")
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
        collectionView.reloadData()
    }
}
