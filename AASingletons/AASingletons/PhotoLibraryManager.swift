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
    final public class override var authorizationStatus : AsyncAuthorization
    {
        get
        {
            let status = PHPhotoLibrary.authorizationStatus()
            
            return _asyncAuthorizationForAuthorization( status )
        }
    }
    
    final internal class override func requestAuthorization( authCallback: AsyncAuthCallback )
    {
        PHPhotoLibrary.requestAuthorization()
        {
            ( newStatus: PHAuthorizationStatus) -> Void in
            
            dispatch_async( dispatch_get_main_queue() )
            {
                ()->Void in
                let asyncStatus : AsyncAuthorization = PhotoLibraryManager._asyncAuthorizationForAuthorization( newStatus )
                authCallback( auth: asyncStatus )
            }
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
    
    //FIXME: temp implementation
    public func getLastPhoto( targetSize: CGSize, completion: ( image: UIImage? ) -> Void ) -> Void
    {
        let imgManager = PHImageManager.defaultManager()

        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        {
            if fetchResult.count > 0
            {
                imgManager.requestImageForAsset( fetchResult.objectAtIndex(fetchResult.count - 1  ) as! PHAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: requestOptions )
                { (image, _) in
                
                    completion( image: image )
                }
            }
        }
    }
}
