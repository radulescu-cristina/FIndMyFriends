//
//  Friend.swift
//  FindMyFriends
//
//  Created by Cristina Radulescu on 12/12/15.
//  Copyright © 2015 Cristina Radulescu. All rights reserved.
//

import UIKit
import Parse

class Friend: ParseObject {
    
    var friendId: String
    var profilePicture: String
    var firstName: String
    var lastName: String
    
    init(id: String, picture: String, fName: String, lName: String) {
        friendId = id
        profilePicture = picture
        firstName = fName
        lastName = lName
    }
    
    func saveEventually() {
        let obj = PFObject(className: "Friend")
        obj["friend_id"] = friendId
        obj["profile_picture"] = profilePicture
        obj["first_name"] = firstName
        obj["last_name"] = lastName
        obj.fetchInBackgroundWithBlock { (o: PFObject?, e: NSError?) -> Void in
            if (o == nil) {
                obj.saveEventually()
            } else {
                print(o)
            }
        }
    }
    
    static func decode(pfObject: PFObject) -> ParseObject
    {
        let friendId = pfObject.valueForKey("friend_id") as! String
        let firstName = pfObject.valueForKey("first_name") as! String
        let lastName = pfObject.valueForKey("last_name") as! String
        let profilePicture = pfObject.valueForKey("profile_picture") as! String
        
        return Friend(id: friendId, picture: profilePicture, fName: firstName, lName: lastName)
    }
}
