//
//  DDNAAuthorizationRequest.swift
//  SwiftTest
//
//  Created by Gregorio on 06/04/15.
//  Copyright (c) 2015 Gregorio. All rights reserved.
//

import Foundation

/**

*/
final public class HashableType : Hashable
{
    public let type : Any.Type
    
    public var hashValue : Int
    {
        return toString( type ).hashValue
    }
    
    public init( type : Any.Type )
    {
        self.type = type
    }
    
    public convenience init( instance: Any )
    {
        self.init( type: instance.dynamicType )
    }
}

public func ==( lhs: HashableType, rhs: HashableType )->Bool
{
    return toString( lhs.type ) == toString( rhs.type )
}




