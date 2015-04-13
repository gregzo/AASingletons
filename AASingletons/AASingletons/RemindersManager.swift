//
//  RemindersManager.swift
//  AASingletons
//
//  Created by Gregorio on 13/04/15.
//  Copyright (c) 2015 Gregzo. All rights reserved.
//

import Foundation
import EventKit

public class RemindersManager : EventKitManager
{
    public override class func entityType() -> EKEntityType
    {
        return EKEntityTypeReminder
    }
}