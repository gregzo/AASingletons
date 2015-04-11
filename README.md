# AASingletons
** Async Authorised Singletons **

A pure Swift framework providing a base classes for singletons interacting with authorization dependent APIs, such as PhotoKit or CoreLocation.

My first Swift project, it hopefully raises some interesting topics regarding design patterns: hiding implementation details to provide as true a black box as possible meant finding workarounds and bending the language in inelegant ways. Proposals for more idiomatic, composition based patterns would be very much welcome!

# Goals

* Prevent direct instantiation of AASingleton derived types
* Funnel all access to instances through AASingleton.getAuthorizedInstance, which may provide instances via an async closure if authorization is needed
* Instantiate specific singletons only if authorization is granted, and provide template implementation for authorization requests
