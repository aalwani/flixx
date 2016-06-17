//
//  MoviesViewController.swift
//  flix
//
//  Created by Aanya Alwani on 6/15/16.
//  Copyright © 2016 Aanya Alwani. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var endpoint: String!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var filteredData: [String]!
    var data = [String]()
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        tableView.dataSource = self
        tableView.delegate = self
        errorView.hidden = true
        loadDataFromNetwork()
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor(red: 0, green: 0.5, blue: 4, alpha: 1)
           
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 6;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(25),
                NSForegroundColorAttributeName : UIColor(red: 0, green: 0, blue: 4.15, alpha: 0.8),
                NSShadowAttributeName : shadow
           ]
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       
        if let movies = movies{
            return movies.count}
        else {return 0}
        //return filteredData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MoviesCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w500"
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        if let posterPath = movie["poster_path"] as? String
        {
            let imageURL = NSURL(string: baseURL + posterPath)
        
            cell.posterView.setImageWithURL(imageURL!)
        }
        return cell
    }
    
    func loadDataFromNetwork()
    {
        let apiKey = "101c085904ea02513468bb4f9c093521"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        var checker = false
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil
            {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary
                {
                    print("response:\(responseDictionary)")
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    self.tableView.reloadData()
                }
                
            }
                        else if error != nil
            {
                self.errorView.hidden = false
                self.errorLabel.text = "There was an error 🙄" + error!.localizedDescription
                checker = true
            }
            if checker == false
            {
                self.errorView.hidden = true
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
        })
        task.resume()
        
        
    }
    
    func getTitle()
    
    {
        for index in 1...(movies!.count-1)
        {
        let moviesss = movies![index]
        let title = moviesss["title"] as! String
        data.append(title)
        }
        
    }
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        self.loadDataFromNetwork()
        self.tableView.reloadData()
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    
    
    // This method updates filteredData based on the text in the Search Box
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
    }
    

}
