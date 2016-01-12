//
//  LoginViewController.swift
//  FindMyFriends
//
//  Created by Cristina Radulescu on 12/8/15.
//  Copyright © 2015 Cristina Radulescu. All rights reserved.
//

import Parse
import Bolts
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {
    
    //@IBOutlet weak var loginButton: UIButton?
    let loginButton = UIButton(type: .System)
    
    let permissions = ["public_profile", "email", "user_friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.backgroundColor = UIColor(red: 0.36, green: 0.48, blue: 0.75, alpha: 1)
        loginButton.setTitle("Log in with Facebook", forState: .Normal)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton.frame = CGRectMake(0,0,180,40);
        loginButton.layer.cornerRadius = 8
        loginButton.center = self.view.center;
        loginButton.addTarget(self, action:"loginButtonClicked", forControlEvents:.TouchUpInside)
        
        self.view.addSubview(loginButton)
    }
    
    override func viewWillLayoutSubviews() {
        loginButton.center = self.view.center;
    }
    
    func _loginWithFacebook()
    {
        
    }
    
    func loginButtonClicked()
    {
//        let loginManager = FBSDKLoginManager()
//        loginManager.logInWithReadPermissions(permissions, fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
//            if (error != nil) {
//                NSLog("Process error")
//            } else if (result.isCancelled) {
//                NSLog("Cancelled")
//            } else {
//                NSLog("Logged in")
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController")
//                self.presentViewController(vc, animated: true, completion: nil)
//            }
//        }
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions){ (user: PFUser?, error: NSError?) -> Void in
            if let user = user
            {
                print(user)
                if user.isNew
                {
                    print("User signed up and logged in through Facebook!")
                }
                else
                {
                    print("User logged in through Facebook!")
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController")
                let fvc = vc.childViewControllers.first as! FirstViewController
                fvc.user = user
                let svc = vc.childViewControllers[1] as! SecondViewController
                svc.user = user
                self.fetchAndSaveUserData(user)
                self.presentViewController(vc, animated: true, completion: nil)
            }
            else
            {
                NSLog("Uh oh. The user cancelled the Facebook login. Error: \(error)");
            }

        }
    }
    
    func fetchAndSaveUserData(user: PFUser) {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name"], HTTPMethod: "GET")
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Return User Data error: \(error)")
            }
            else
            {
                print (result)
                user.email = result.valueForKey("email") as? String
                
                //look for the user's email address in the database
                //let task:BFTask = self.searchUser(user.email!)
                //self.searchUser(user.email!, continueWithBlock: { () -> Void in
                    user.saveEventually()
                if (user.isNew) {
                    self.fetchAndSaveFriendsData(user)
                }
                //})
            }
        })
    }
    
    func fetchAndSaveFriendsData(user: PFUser, next: String? = nil)
    {
        let request = FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: ["fields":"first_name, last_name, picture.type(large), id", "limit":"5000"], HTTPMethod: "GET")
        
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                NSLog("Return Friends list Error: \(error)")
            }
            else {
                print(result)
                let friendsArray = result.valueForKey("data") as! NSArray
                for f in friendsArray {
                    let id = f.valueForKey("id") as! String
                    let picture = f.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as! String
                    let fName = f.valueForKey("first_name") as! String
                    let lName = f.valueForKey("last_name") as! String
                    let friend = Friend(id: id, picture: picture, fName: fName, lName: lName)
                    let relation = FriendRelation(friend: friend, user: user)
                    friend.saveEventually()
                    relation.saveEventually()
                }
            }
        }
    }
}
