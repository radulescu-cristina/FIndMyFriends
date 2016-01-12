//
//  ParseObject.swift
//  FindMyFriends
//
//  Created by Cristina Radulescu on 12/12/15.
//  Copyright © 2015 Cristina Radulescu. All rights reserved.
//

import Parse

protocol ParseObject {
    func saveEventually()
    static func decode(pfObject: PFObject) -> ParseObject
}
