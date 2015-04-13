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
        
        let result = RemindersManager.getAuthorizedInstance { (authorizedInstance: RemindersManager? ) -> Void in
            
            println( authorizedInstance )
        }
        
        println( result )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

