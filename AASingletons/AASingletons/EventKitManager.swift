//
//  EventKitManager.swift
//  AASingletons
//
//  Created by Gregorio on 13/04/15.
//  Copyright (c) 2015 Gregzo. All rights reserved.
//

import Foundation
import EventKit

public class EventKitManager : AASingleton
{
    final public class override var authorizationStatus : AsyncAuthorization
    {
        get
        {
            let status = EKEventStore.authorizationStatusForEntityType( self.entityType() )
        
            return _asyncAuthorizationForAuthorization( status )
        }
    }
    
    public class func entityType() -> EKEntityType
    {
        return -1
    }
    
    final public var eventStore : EKEventStore
    {
        return EventKitManager.__eventStore
    }
    
    public var calendars : [ EKCalendar ]?
    {
        return self.eventStore.calendarsForEntityType( self.dynamicType.entityType() ) as? [ EKCalendar ]
    }
    
    final internal class override func requestAuthorization( authCallback: AsyncAuthCallback )
    {
        self.__eventStore.requestAccessToEntityType( self.entityType() )
            { ( granted: Bool, error: NSError! ) -> Void in
                
                dispatch_async( dispatch_get_main_queue() )
                    { () -> Void in
                        authCallback( auth: self.authorizationStatus )
                }
        }
    }
    
    private static var __eventStore: EKEventStore = EKEventStore()
    
    private class func _asyncAuthorizationForAuthorization( status: EKAuthorizationStatus ) -> AsyncAuthorization
    {
        switch status
        {
        case .Authorized:
            return AsyncAuthorization.Authorized
            
        case .Denied, .Restricted:
            return AsyncAuthorization.Denied
            
        case .NotDetermined:
            return AsyncAuthorization.NotDetermined
        }
    }
    
    required public init?( token: Any )
    {
        super.init(token: token)
        
        if toString( self.dynamicType ) == toString( EventKitManager.self )
        {
            println( "Cannot instantiate pseudo-abstract class EventKitManager" )
            return nil
        }
    }
}