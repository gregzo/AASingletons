//
//  EventKitBase.swift
//  AASingletons
//
//  Created by Gregorio on 13/04/15.
//  Copyright (c) 2015 Gregzo. All rights reserved.
//

import Foundation
import EventKit

public class CalendarManager : EventKitManager
{
    required public init?( token: Any )
    {
        
        super.init(token: token)
        
        if toString( self.dynamicType ) == toString( EventKitManager.self )
        {
            println( "Cannot instantiate pseudo-abstract class EventKitManager" )
            return nil
        }
    }

    
    final public override class func entityType() -> EKEntityType
    {
        return EKEntityTypeEvent
    }
}


