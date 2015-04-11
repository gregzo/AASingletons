# AASingletons
**Async Authorised Singletons**

A pure Swift framework providing a base classes for singletons interacting with authorization dependent APIs, such as *Photos* or *CoreLocation*.

My first Swift project, it hopefully raises some interesting topics regarding design patterns: hiding implementation details to provide as true a black box as possible meant finding workarounds and bending the language in inelegant ways. Proposals for more idiomatic, composition based patterns would be very much welcome!

*AASingleton* is the pseudo abstract base class handling callbacks and instantiation / refs of specific subclass instances.
*PhotoLibraryManager* and *LocationManager* are example implementations of *AASingleton* derived classes. They may be derived themselves.

**Use**

( *PhotoLibraryManager* derives from *AASingleton* )

        let result = PhotoLibraryManager.getAuthorizedInstance()
        { ( authorizedInstance: PhotoLibraryManager? ) -> Void in
            // Authorization closure
            if authorizedInstance == nil
            {
                println( "Authorization denied" )
            }
            else
            {
                println( "Authorization granted, please help yourself to the instance" )
                let manager = authorizedInstance!
            }
        }
        
        switch result.status
        {
        case .Denied:
            println( "User has already denied authorization" )
            
        case .Granted:
            println( "User has already granted authorization, enjoy the instance!" )
            //access manager from result tuple
            let manager = result.authorizedInstance!
            
        case .WaitingForAuthorization:
            println( "Authorization requested, please be patient whilst the user thinks about it." )
        }

# Goals

* Provide a pseudo-abstract base class for singleton types which depend on user authorized APIs
* Prevent direct instantiation of *AASingleton* derived types
* Funnel all access to instances through *AASingleton.getAuthorizedInstance*, which may provide instances via an async closure if authorization is needed
* Instantiate specific singletons only if authorization is granted, and provide template implementation for authorization requests

# Challenges

1. For *AASingleton* to be able to instantiate any derived type, *getAuthorizedInstance* is implemented as a generic method where *T* is inferred from the *authCallback* closure parameter type. As generics can only be instantiated if a *required public* initializer is implemented, this meant exposing derived class initializers which would very much defeat the purpose. Hacky workaround: the required init takes a token parameter which only the base class can provide ( implemented as a random Int ). This fakes protected behaviour, functional but very inelegant.

2. *AASingleton* must keep references to each derived instance, and serve them upon request. Problem: how to identify instances? The obvious solution is a dictionary of instances stored by type, but Swift's *Any.Type* does not implement *Hashable*. My workaround was to implement a small wrapper, *HashableType*, and an internal helper class, *TypeDictionary*( declared in *AASingleton.swift* )

3. In the case where requesting an instance triggers an authorization request, *AASingleton* must store a reference to the callback to be executed when authorization is granted/denied. Problem: closures aren't castable even if parameters and return types are compatible. How to store callbacks passing specific *AASingleton* instances in the same dictionary then? My solution here was again a small generic wrapper, *GenericCallback*, which keeps a private reference to a specific callback and publicly exposes a closure of type *( value: Any? )->Void*. It simply casts value to *T* and fires the specific callback if the cast succeeds.

4. 
