//
//  NLFDownloadManager.swift
//  FindMyFriends
//
//  Created by Cristina Radulescu on 1/12/16.
//  Copyright © 2016 Cristina Radulescu. All rights reserved.
//

import UIKit

let kNLFDownloadManagerDidDownloadImage = "kNLFDownloadManagerDidDownloadImage"
var downloadedImages = [String: UIImage]()

public class NLFDownloadManager: NSObject
{
    var observer: AnyObject?
    public func downloadImage(url: String, useCache: Bool, inBackground: Bool, observer: AnyObject)
    {
        self.observer = observer
        if (useCache) {
            if let image = downloadedImages[url] {
                self.postImage(image)
                return
            }
        }
        
        if (inBackground) {
            var imgURL = NSURL(string: url)
            let request = NSURLRequest(URL: imgURL!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    if let image = UIImage(data: data!) {
                        downloadedImages[url] = image
                        dispatch_async(dispatch_get_main_queue(), {
                            self.postImage(image)
                            return
                        })
                    }
                }
            })
        }
    }
    
    func postImage(image: UIImage)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(kNLFDownloadManagerDidDownloadImage, object: self, userInfo:["image": image])
    }
}
