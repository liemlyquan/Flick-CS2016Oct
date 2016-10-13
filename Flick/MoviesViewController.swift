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
import SystemConfiguration
import DZNEmptyDataSet


class MoviesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var noNetworkConnectionLabel: UILabel!

    

    var movies:[NSDictionary] =  []
    var filteredMovies:[NSDictionary] = []
    var endpoint = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        initDelegate()
        initRefreshControl()
        // TODO: handle refresh, and if possible, load offline data
        if (connectedToNetwork()){
            loadMovie(nil)
        } else {
            noNetworkConnectionLabel.alpha = 1
            // Thanks to AntiStrike12
            // stackoverflow.com/questions/28288476/fade-in-and-fade-out-in-animation-swift
            UIView.animate(withDuration: 2, delay: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.noNetworkConnectionLabel.alpha = 0
            }, completion: nil )
        }
        
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
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        //        collectionView.delegate = self
        //        collectionView.dataSource = self
    }
    
    func initRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMovie(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func initUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        segmentedControl.frame.size.height = searchBar.frame.height
    }
    
    // TOOD: To make it "more correct", should not need refresh control
    func loadMovie(_ refreshControl: UIRefreshControl? = nil){
        let url = "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(GlobalConstants.apiKey)"
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
                                refreshControl?.endRefreshing()
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
}

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension MoviesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let view = Bundle.main.loadNibNamed("EmptyDataView", owner: self, options: nil)?.last as! UIView
        tableView.tableFooterView = UIView(frame: .zero)
        return view
        
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
