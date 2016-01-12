//
//  FriendRelation.swift
//  FindMyFriends
//
//  Created by Cristina Radulescu on 12/12/15.
//  Copyright © 2015 Cristina Radulescu. All rights reserved.
//

import Parse

class FriendRelation: ParseObject {
    var friend: Friend
    var user: PFUser
    
    init(friend: Friend, user: PFUser) {
        self.friend = friend
        self.user = user
    }
    
    func saveEventually() {
        let obj = PFObject(className: "FriendRelation")
        obj["friend_id"] = friend.friendId
        obj["user_id"] = user.objectId
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
