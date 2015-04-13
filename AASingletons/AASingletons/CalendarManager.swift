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
    public override class func entityType() -> EKEntityType
    {
        return EKEntityTypeEvent
    }
}


