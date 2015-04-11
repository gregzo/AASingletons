//
//  LocationManager.swift
//  GAuthorizedSingleton
//
//  Created by Gregorio on 10/04/15.
//  Copyright (c) 2015 Gregorio. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationManager: AASingleton
{
    // ----------------------------------------------------------------------------------
    // --------------------------       Public          ---------------------------------
    // ----------------------------------------------------------------------------------
    
    //MARK: - Public
    
    /*
        Readonly access. May return nil if the user 
        denies location authorization in settings while 
        app is running
    */
    public var clLocationManager : CLLocationManager?
    {
        return LocationManager.__clLocationManager
    }
    
    /**
        Set to true before requesting an instance to ask for always on permission.
        Default is false and will ask for when in use permission.
    */
    public static var requestAlways : Bool = false
    
    // ----------------------------------------------------------------------------------
    // -------------------------- Compulsory Overrides  ---------------------------------
    // ----------------------------------------------------------------------------------
    
    //MARK: - Compulsory Overrides
    
    public class override var authorizationStatus : AsyncAuthorization
    {
        get
        {
            let status = CLLocationManager.authorizationStatus()
            let asyncAuth : AsyncAuthorization = _asyncAuthorizationForLocationAuthorization( status )
            return asyncAuth
        }
    }
    
    internal class override func requestAuthorization( callback: AsyncAuthCallback )
    {
        // called by super class only when auth is .NotDetermined
        // we'll need a CLLocationManager to request auth, and a temporary LocationAuthRequest instance
        // to perform the request( setting itself as delegate and firing a callback )
        if __clLocationManager == nil
        {
            __clLocationManager = CLLocationManager()
        }
        
        // No strong ref to request is needed: it will retain and release itself
        let request = LocationAuthRequest( manager: __clLocationManager!, always: requestAlways, authCallback:
            {
                ( newStatus: AsyncAuthorization ) -> Void in
                
                if newStatus != AsyncAuthorization.Authorized
                {
                    LocationManager.__clLocationManager = nil
                }
                
                callback( auth: newStatus )
        })
    }
    
    // ----------------------------------------------------------------------------------
    // -------------------------- Private and Internal ----------------------------------
    // ----------------------------------------------------------------------------------
    
    //MARK: - Private and Internal
    
    private static var __clLocationManager : CLLocationManager?
    
    /**
    required init: always call super first, which may fail and stop initialization
    */
    required public init?( token: Any )
    {
        super.init(token: token)
        
        if LocationManager.__clLocationManager == nil
        {
            LocationManager.__clLocationManager = CLLocationManager()
        }
    }
    
    /**
        Map CLAuthorizationStatus to AsyncAuthorization
    */
    internal static func _asyncAuthorizationForLocationAuthorization( status: CLAuthorizationStatus ) -> AsyncAuthorization
    {
        switch status
        {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return AsyncAuthorization.Authorized
            
        case .Denied, .Restricted:
            return AsyncAuthorization.Denied
            
        case .NotDetermined:
            return AsyncAuthorization.NotDetermined
        }
    }
    
    
    
    //MARK: Nested Delegate to Closure Helper
    /**
        Nested helper class which sets itself temporarily as delegate of CLLocationManager
        Also checks for presence in info.plist of the appropriate usage description key, and logs
        if not present
    */
    internal class LocationAuthRequest : NSObject, CLLocationManagerDelegate
    {
        var callback : AsyncAuthCallback!
        
        private var selfRef : LocationAuthRequest?
        
        internal required init?( manager: CLLocationManager, always: Bool, authCallback: AsyncAuthCallback )
        {
            let currentAuth = CLLocationManager.authorizationStatus()
            
            if currentAuth != CLAuthorizationStatus.NotDetermined
            {
                self.callback = nil
                super.init()
                return nil
            }
            
            let key = always ? "NSLocationAlwaysUsageDescription" : "NSLocationWhenInUseUsageDescription"
            let desc : String? = NSBundle.mainBundle().objectForInfoDictionaryKey( key ) as? String
            if desc == nil
            {
                self.callback = nil
                super.init()
                println( "\( key ) missing in plist" )
                return nil
            }
            
            
            self.callback = authCallback
            super.init()
            
            manager.delegate = self
            
            // need strong ref to not be deallocated whilst waiting for auth
            self.selfRef = self
            
            if always
            {
                manager.requestAlwaysAuthorization()
            }
            else
            {
                manager.requestWhenInUseAuthorization()
            }
        }
        
        internal func locationManager( manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus )
        {
            // may happen, strangely...
            if status == CLAuthorizationStatus.NotDetermined
            {
                return
            }
            manager.delegate = nil
            self.callback( auth: LocationManager._asyncAuthorizationForLocationAuthorization( status ) )
            self.selfRef = nil
        }
    }
}



