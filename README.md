# AASingletons
** Async Authorised Singletons **

A pure Swift framework providing a base classes for singletons interacting with authorization dependent APIs, such as PhotoKit or CoreLocation.

My first Swift project, it hopefully raises some interesting topics regarding design patterns: hiding implementation details to provide as true a black box as possible meant finding workarounds and bending the language in inelegant ways. Proposals for more idiomatic, composition based patterns would be very much welcome!

# Goals

* Provide a pseudo-abstract base class for singleton types which depend on user authorized APIs
* Prevent direct instantiation of AASingleton derived types
* Funnel all access to instances through AASingleton.getAuthorizedInstance, which may provide instances via an async closure if authorization is needed
* Instantiate specific singletons only if authorization is granted, and provide template implementation for authorization requests

# Challenges

1. For AASingleton to be able to instantiate any derived type, getAuthorizedInstance is implemented as a generic method where T is inferred from the authCallback closure parameter type. As generics can only be instantiated through a required public init, this meant exposing derived class initializers which would very much defeat the purpose. Hacky workaround: the required init takes a token parameter which only the base class can provide ( implemented as a random Int ). This fakes protected behaviour, functional but very inelegant.
2. 
