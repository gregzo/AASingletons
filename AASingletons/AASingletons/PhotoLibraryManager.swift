//
//  PhotoLibraryManager.swift
//  SwiftTest
//
//  Created by Gregorio on 07/04/15.
//  Copyright (c) 2015 Gregorio. All rights reserved.
//

import Foundation
import Photos

public class PhotoLibraryManager: AASingleton
{
    public class override var authorizationStatus : AsyncAuthorization
    {
        get
        {
            let status = PHPhotoLibrary.authorizationStatus()
            
            return _asyncAuthorizationForAuthorization( status )
        }
    }
    
    internal class override func requestAuthorization( authCallback: AsyncAuthCallback )
    {
        PHPhotoLibrary.requestAuthorization()
        {
            ( newStatus: PHAuthorizationStatus) -> Void in
            let asyncStatus : AsyncAuthorization = PhotoLibraryManager._asyncAuthorizationForAuthorization( newStatus )
            authCallback( auth: asyncStatus )
        }
    }
    
    private class func _asyncAuthorizationForAuthorization( status: PHAuthorizationStatus ) -> AsyncAuthorization
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
    }
}