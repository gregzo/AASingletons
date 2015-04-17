//
//  ViewController.swift
//  AASingletonsExample
//
//  Created by Gregorio on 13/04/15.
//  Copyright (c) 2015 Gregzo. All rights reserved.
//

import UIKit
import AASingletons

class ViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var activity : UIActivityIndicatorView?;
        
        let result = PhotoLibraryManager.getAuthorizedInstance( authorizationCallback:
        {                                                     ( authorizedInstance: PhotoLibraryManager? ) -> Void in
            
            activity?.stopAnimating()
            activity?.removeFromSuperview()
            self.displayLastPic()
        })
        
        if result.status == AAInstanceRequestStatus.WaitingForAuthorization
        {
            activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray )
            activity?.center = self.view.center
            activity?.frame.origin.y = 50
            activity?.color = UIColor.blueColor()
            self.view.addSubview( activity! )
            activity?.startAnimating()
        }
        else if result.status == AAInstanceRequestStatus.Granted
        {
            self.displayLastPic()
        }
        
        let calResult = CalendarManager.getAuthorizedInstance( authorizationCallback:
        {                                                    ( authorizedInstance: CalendarManager? ) -> Void in
            println( authorizedInstance?.calendars )
        })
        
        println( calResult.authorizedInstance?.calendars )
    }
    
    private func displayLastPic()
    {
        var frame = self.view.frame
        frame.size.height = frame.width
        frame.origin.y = 50
        let lastPic = LastPicView( frame: frame )
        self.view.addSubview( lastPic )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


class LastPicView: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame )
        
        let result = PhotoLibraryManager.getAuthorizedInstance( authorizationCallback:
        {                                                     ( authorizedInstance: PhotoLibraryManager? ) -> Void in
            
            authorizedInstance?.getLastPhoto( frame.size, completion: self.setImage )
        })
        
        result.authorizedInstance?.getLastPhoto( frame.size, completion: self.setImage )
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setImage( image: UIImage? )
    {
        if image == nil
        {
            return
        }
        let imageView = UIImageView( frame:  self.bounds )
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = image!
        self.addSubview( imageView )
    }
}
