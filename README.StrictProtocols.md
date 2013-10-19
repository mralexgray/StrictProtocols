# NSObject+StrictProtocols
---
###Raison d'être
The cure to the ~~common cold~~ `NSObject`'s flawed implementation of 

    - (BOOL)conformsToProtocol:(Protocol *)aProtocol;

which Apple boasts..
> Returns `YES` if the receiving class conforms to `aProtocol`, `NO` otherwise. This method works identically to the `conformsToProtocol:` class method declared in `NSObject`. It's provided as a convenience so that you don't need to get the class object to find out whether an instance can respond to a given set of messages.

While this _all sounds great_... In **reality**... ALL it does is look for the object's _declaration of conformance_, i.e. `<SomeProtcol>`.  This.. is.. ghetto.
    if ([myButt respondsToSelector:@selector(wipe:withBabyWipes)])
        [myButt wipe:self withBabyWipes:YES]; blah, blah, blah...
is like,  sooo tiresome - especially since `myButt` CLAIMS to conform to `<MyButtWipingProtocol>`.  Here is my solution. Given the protocol...

    @protocol StrictProtocol 
    - (void) unspecifiedMethod;
    @required
	 @property (readonly) id requiredMethod;
	 @optional
	 - (void) optionalMethod;        
	 @end

and some objects that claim to conform to it..

    @interface  NonComformantObject : NSObject <StrictProtocol>  @end
    @interface SemiComformantObject : NonComformantObject		 @end
    @interface     ConformantObject : SemiComformantObject 		 @end

    @implementation            ConformantObject
    - (void)  optionalMethod   {             }                   @end
    @implementation            SemiComformantObject
    -   (id) requiredMethod    { return @""; }
    - (void) unspecifiedMethod {             }                   @end
    @implementation            NonComformantObject               @end

    ConformantObject      * strict;
    SemiComformantObject  * semi;
    NonComformantObject   * non;
    Protocol              * proto = @protocol(StrictProtocol);
	 
you can now safely test, cache the results of, and act knowing if the class, or it's acestors ACTUALLY implement a protocol's methods.

###Panacea

	/* "non" doesn't implement ANY of the declared methods! */
	[non implementsProtocol:proto];         -> NO;
	[non implementsFullProtocol:proto];     -> NO;

	/* "semi" doesn't implement the @optional methods */
	[semi implementsProtocol:proto]; 	    -> YES;
	[semi implementsFullProtocol:proto];    -> NO;	
	
	/* "strict" implements ALL, ie the @optional, @required, and the "unspecified" methods */
	[strict implementsProtocol:proto]; 	    -> YES;
	[strict implementsFullProtocol:proto];  -> YES;	
Results of previously fetched conformance info are cached (for speed?). If desired, you can summon them, unto an `NSDictionary` via..

	[SomeClass cachedConformance];
    
### Compatibility


* Supported build target - iOS 2.0+ / Mac OS 10.5+ (Xcode 2.0 or greater, _please_)
* Only tested under ARC - because manual memory management kills babies.

Installation
--------------

It's a category on `NSObject`, dum-dum!  Simply add the files to your project, and make sure the `.m` file is part of your "compilation unit" <hehehe>, i.e. it's under "Compile Sources" in "Build Phase".

PS. Stay sexy, gorgeous.
