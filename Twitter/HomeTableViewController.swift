//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Chris Koehne on 2/13/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit
  
class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numTweets: Int!
    let refreshTweetsControl = UIRefreshControl()
    
    override func viewDidLoad() {
//        self.tableView.rowHeight = 100
        super.viewDidLoad()
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
        loadTweets()
        refreshTweetsControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = refreshTweetsControl
    }
    
    @objc func loadTweets() {
        
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": 15]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: params, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.refreshTweetsControl.endRefreshing()
        }, failure: { (Error) in
            print("Error retrieving tweets")
        })
    }
    
    func loadMoreTweets() {
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let newCount: Int = tweetArray.count + 15
        let params = ["count": newCount]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: params, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("Error retrieving more tweets")
        })
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }

    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.usernameLabel.text = user["name"] as? String
        cell.tweetContentLabel.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return self.numTweets
        return tweetArray.count
    }

}
