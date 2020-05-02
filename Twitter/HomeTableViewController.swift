//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Jianling Su on 4/25/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    var tweetTable: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
       // numberOfTweets = 20
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 150
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        self.loadTweets()
    }
 
    
    //load tweet
    @objc func loadTweets(){
        //search and go to Tweet API, get tweet timetine url
        
        numberOfTweets = 20
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        let myParams = ["count": numberOfTweets]
        
        //pull tweet
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: {(tweets:[NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            //for every single tweet int tweets
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        } , failure: {(Error) in
            print("Could not retreive tweets! oh no!")
        })
    }
    
    //load more tweet , the above fun load first 20 tweets

    func loadMoreTweets(){
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        //originally it's 20
        
        numberOfTweets = numberOfTweets + 20
       
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: {(tweets:[NSDictionary]) in
                 
                 self.tweetArray.removeAll()
                 
                 //for every single tweet int tweets
                 for tweet in tweets{
                     self.tweetArray.append(tweet)
                 }
                 
                 self.tableView.reloadData()
                 
             } , failure: {(Error) in
                 print("Could not retreive tweets! ohoh no!")
             })
        
    }
   
    // when the user gets to the end of the page, load more tweets
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath){
        if indexPath.row + 1 == tweetArray.count{
            loadMoreTweets()
        }
    }
    
    //logout from twitter by clicking logout
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String

        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)!
        let data = try? Data(contentsOf: imageUrl)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorited(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
       // cell.retweeted = tweetArray[indexPath.row]["retweeted"] as! Bool
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        return cell
    }
   
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

   

}
