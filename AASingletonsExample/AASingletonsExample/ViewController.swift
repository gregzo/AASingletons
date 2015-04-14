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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let result = PhotoLibraryManager.getAuthorizedInstance { (authorizedInstance: PhotoLibraryManager? ) -> Void in
            
            println( authorizedInstance )
        }
        
        println( result.status )
        
        self.view.addSubview( LastPicView(frame: CGRectMake( 50, 50, 200, 200 ) ) )
        
        let res2 = LocationManager.getAuthorizedInstance { (authorizedInstance: LocationManager? ) -> Void in
            
            println( authorizedInstance )
        }
        
        println( res2 )
        
        let res3 = AddressBookManager.getAuthorizedInstance { (authorizedInstance: AddressBookManager? ) -> Void in
            
            println( authorizedInstance )
        }
        
        println( res3 )
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
        
        let result = PhotoLibraryManager.getAuthorizedInstance { (authorizedInstance: PhotoLibraryManager? ) -> Void in
            
            authorizedInstance?.getLastPhoto( frame.size, completion: self.setImage )
        }
        
        result.authorizedInstance?.getLastPhoto( frame.size, completion: setImage )
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
        let imageView = UIImageView(frame:  self.bounds )
        imageView.image = image!
        self.addSubview( imageView )
    }
}
