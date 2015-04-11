//
//  GenericsTest.swift
//  SwiftTest
//
//  Created by Gregorio on 07/04/15.
//  Copyright (c) 2015 Gregorio. All rights reserved.
//

import Foundation

final public class GenericCallback< T >
{
    func executeCallback( value: Any? ) -> Void
    {
        if let specificValue = value as? T
        {
            specificCallback( value: specificValue )
        }
    }
    
    init( callback: ( value: T? )->Void )
    {
        self.specificCallback = callback
    }
    
    private let specificCallback : ( value: T? )->Void
}