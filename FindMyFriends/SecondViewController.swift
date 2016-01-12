//
//  SecondViewController.swift
//  FindMyFriends
//
//  Created by Cristina Radulescu on 12/8/15.
//  Copyright © 2015 Cristina Radulescu. All rights reserved.
//


import Parse
import UIKit

class SecondViewController: UITableViewController {
    
    var user: PFUser?
    var friends: [Friend] = []
    var downloadedImages = [String: UIImage]()
    let kNLFDownloadManagerDidDownloadImage = "kNLFDownloadManagerDidDownloadImage"
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let user = self.friends[indexPath.row]
       
        let userImageView = NLFDownloadableImageView()
        var cell = self.tableView.dequeueReusableCellWithIdentifier("friendCell")
        if (nil == cell) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "friendCell")
        }
       
        userImageView.URLString = user.profilePicture
        //let url = NSURL(string: user.profilePicture)
        //let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        cell!.imageView?.image = userImageView.image //UIImage(data: data!)
       
        cell!.textLabel?.text = user.firstName + " " + user.lastName
       
        return cell!
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let objID: String? = user?.objectId
        
        //retrieve info from the current user's friends
        searchAllFriendsUser(objID!)
    }
    
    func searchAllFriendsUser(userID: String)
    {
        let query = PFQuery(className: "FriendRelation")
        var friendsID: [String] = []
        query.whereKey("user_id", equalTo: userID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil
            {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects
                {
                    for object in objects
                    {
                        //search for obj in Friend database
                        let friendId = object.valueForKey("friend_id") as! String
                        friendsID.append(friendId)
                    }
                }
                print("Successfully retrieved \(objects!.count) scores.")
                self.searchUserInfo(friendsID)
            }
            else
            {
                print("Error finding user in database: \(error)")
            }
            
        }
    }
    
    func searchUserInfo(friendsID: [String])
    {
        let query = PFQuery(className : "Friend")
        for var i = 0; i < friendsID.count; i++
        {
            query.whereKey("friend_id", equalTo: friendsID[i])
            do
            {
                let friend = try query.getFirstObject()
                print("Friend found: \(i)")
            
                //show all info
                let user: Friend = Friend.decode(friend) as! Friend
                self.friends.append(user)
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
            }
            catch
            {
                print(error)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: String){
        print("Download Started")
        let imgURL = NSURL(string: url)
        let request = NSURLRequest(URL: imgURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
            if error == nil {
                if let image = UIImage(data: data!) {
                    self.downloadedImages[url] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        self.postImage(image)
                        return
                    })
                }
            }
        })
        
    }
    
    func postImage(image: UIImage)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(kNLFDownloadManagerDidDownloadImage, object: self, userInfo:["image": image])
    }
}