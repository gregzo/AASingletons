//
//  AddressBookManager.swift
//  AASingletons
//
//  Created by Gregorio on 13/04/15.
//  Copyright (c) 2015 Gregzo. All rights reserved.
//

import Foundation
import AddressBook

public class AddressBookManager : AASingleton
{
    public class override var authorizationStatus : AsyncAuthorization
    {
        get
        {
            let status = ABAddressBookGetAuthorizationStatus()
        
            return _asyncAuthorizationForAuthorization( status )
        }
    }
    
    public var addressBook : ABAddressBookRef!
    {
        return AddressBookManager.__addressBook
    }
    
    private static var __addressBook : ABAddressBookRef!
    
    internal class override func requestAuthorization( authCallback: AsyncAuthCallback )
    {
        var err : Unmanaged< CFErrorRef >?
        var addressBook: ABAddressBookRef!
        
        if let abRef = ABAddressBookCreateWithOptions( nil, &err )
        {
            __addressBook = abRef.takeRetainedValue()
        }
        else
        {
            if err != nil
            {
                println( err )
            }
            
            authCallback( auth: AsyncAuthorization.Denied )
            
            return
        }
        
        var handler : ABAddressBookRequestAccessCompletionHandler! = { ( granted: Bool, error: CFError! ) -> Void in
            
            if granted == false
            {
                AddressBookManager.__addressBook = nil
            }
            
            authCallback( auth: AddressBookManager.authorizationStatus )
        }
        
        ABAddressBookRequestAccessWithCompletion( addressBook, handler )
    }
    
    private class func _asyncAuthorizationForAuthorization( status: ABAuthorizationStatus ) -> AsyncAuthorization
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
        
        if AddressBookManager.__addressBook == nil
        {
            if let abRef = ABAddressBookCreateWithOptions( nil, nil )
            {
                AddressBookManager.__addressBook = abRef.takeRetainedValue()
            }
            else
            {
                return nil
            }
        }
    }
}
