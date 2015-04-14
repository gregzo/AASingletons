//
//  AuthorizedSingleton.swift
//  SwiftTest
//
//  Created by Gregorio on 06/04/15.
//  Copyright (c) 2015 Gregorio. All rights reserved.
//

import Foundation


public enum AsyncAuthorization
{
    case NotDetermined, Authorized, Denied
}

public enum AAInstanceRequestStatus
{
    case Granted, Denied, WaitingForAuthorization
}

internal typealias AsyncAuthCallback = ( auth: AsyncAuthorization ) -> Void

public class AASingleton
{
    // ----------------------------------------------------------------------------------
    // --------------------------       Public          ---------------------------------
    // ----------------------------------------------------------------------------------
    
    //MARK: - Public
    
    /**
    The only way to retrieve an instance of an AASingleton derived type.
    
    :param: authCallback Fires only if requesting an instance triggers an authorization request.
    
    :returns: a tuple containing both the instance( if already authorized ) and an instance request status. If status == .WaitingForAuthorization, authCallback will fire when authorization is granted/denied.
    */
    final public class func getAuthorizedInstance< T where T : AASingleton >( authCallback: ( authorizedInstance: T? )->Void )
        -> ( authorizedInstance: T?, status: AAInstanceRequestStatus )
    {
        let status : AsyncAuthorization = T.authorizationStatus
        
        switch status
        {
            
        case .Authorized:
            
            if let singleton : T = __sharedInstances.getObjectForType( T ) as? T
            {
                return ( singleton, AAInstanceRequestStatus.Granted )
            }
            else
            {
                let singleton : AASingleton? = T( token: AASingleton.__token  )
                __sharedInstances.setObjectForType( singleton, type: T.self )
                return ( singleton as? T, AAInstanceRequestStatus.Granted )
            }
            
        case .Denied:
            return ( nil, AAInstanceRequestStatus.Denied )
            
        case .NotDetermined:
            
            var callbacks = __callbacks.getObjectForType( T )
            let genericCallback = GenericCallback( callback: authCallback ).executeCallback
            
            if callbacks == nil
            {
                callbacks = [ genericCallback ]
                __callbacks.setObjectForType( callbacks, type: T.self )
                
                requestAuthorization()
                    { ( status: AsyncAuthorization ) -> Void in
                        
                        let instance : AASingleton?
                        
                        if status == AsyncAuthorization.Authorized
                        {
                            instance = T( token: AASingleton.__token )
                            AASingleton.__sharedInstances.setObjectForType( instance, type: T.self )
                        }
                        else
                        {
                            instance = nil
                        }
                        
                        // re-capture
                        callbacks = AASingleton.__callbacks.getObjectForType( T )
                        
                        for callback in callbacks!
                        {
                            callback( value: instance )
                        }
                        
                        AASingleton.__callbacks.setObjectForType( nil, type: T.self )
                }
            }
            else
            {
                callbacks?.append( genericCallback )
                __callbacks.setObjectForType( callbacks, type: T.self )
            }
            
            return ( nil, AAInstanceRequestStatus.WaitingForAuthorization )
        }
    }
    
    // ----------------------------------------------------------------------------------
    // -------------------------- Compulsory Overrides  ---------------------------------
    // ----------------------------------------------------------------------------------
    
    //MARK: - Compulsory Overrides
    
    /**
    Compulsory override: map specific authorization status to AsyncAuthorization in derived classes.
    */
    public class var authorizationStatus : AsyncAuthorization
    {
        get
        {
            println( "must override authorizationStatus!" )
            assert( false )
        }
    }
    
    /**
    Compulsory override: request specific authorization and fire the authCallback in derived classes.
    Only called if authorizationStatus returns .NotDetermined.
    */
    internal class func requestAuthorization( authCallback: AsyncAuthCallback )
    {
        println( "must override requestAuthorization!" )
        assert( false )
    }
    
    // ----------------------------------------------------------------------------------
    // -------------------------- Private and Internal ----------------------------------
    // ----------------------------------------------------------------------------------
    
    //MARK: - Private and Protected
    
    internal typealias GenericCallbackType = ( value: Any? ) -> Void
    
    private static var __sharedInstances = TypeDictionary< AASingleton >()
    private static var __callbacks = TypeDictionary< [ GenericCallbackType ] >()
    private static var __token : Int = random()
    
    // placing required initializer in the private section as it fakes protected access control
    /**
    Initializer must unfortunately be public so that generic types deriving AASingleton can be instantiated.
    Attempting to directly instantiate will return nil.
    
    :param: token An internal token preventing direct instantiation
    */
    required public init?( token: Any )
    {
        let intToken = token as? Int
        
        if ( intToken == nil ) || intToken != AASingleton.__token
        {
            println( "Cannot directly instantiate AASingleton objects, use getAuthorizedInstance instead." )
            assert( false )
        }
    }
}

// Can't nest generic type, declaring it here
final internal class TypeDictionary< ValueType >
{
    private lazy var _dic = Dictionary< String, ValueType >()
    
    func getObjectForType< T >( type: T.Type ) -> ValueType?
    {
        return _dic[ toString( type ) ]
    }
    
    func setObjectForType( object: ValueType?, type: Any.Type )
    {
        _dic[ toString( type ) ] = object
    }
}