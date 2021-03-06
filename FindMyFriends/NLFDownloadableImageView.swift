//
//  NLFDownloadableImageView.swift
//  FindMyFriends
//
//  Created by Cristina Radulescu on 1/12/16.
//  Copyright © 2016 Cristina Radulescu. All rights reserved.
//

import UIKit


public class NLFDownloadableImageView: UIImageView
{
    var internalURLString: String?
    var downloadManager = NLFDownloadManager()
    
    public init()
    {
        super.init(image: nil, highlightedImage: nil)
        setup()
    }
    
    required public init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDownloadImage:", name: kNLFDownloadManagerDidDownloadImage, object: downloadManager)
    }
    
    public var URLString: String?
        {
        set {
            internalURLString = newValue
            startDownload ()
        }
        get {
            return internalURLString
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kNLFDownloadManagerDidDownloadImage, object: downloadManager)
    }
    
    func startDownload()
    {
        if (self.internalURLString != nil) {
            downloadManager.downloadImage(self.internalURLString!, useCache: true, inBackground: true, observer: self)
        }
    }
    
    @objc func didDownloadImage(notification: NSNotification)
    {
        if (notification.userInfo != nil) {
            let userInfo = notification.userInfo as! Dictionary<String, UIImage>
            dispatch_async(dispatch_get_main_queue()) {
                self.image = userInfo["image"] as UIImage?
            }
        }
    }
}
