
/**  NSObject+StrictProtocols.m  *//* 𝘗𝘈𝘙𝘛 𝘖𝘍 𝗔𝖳𝖮𝗭.𝖥𝖱𝖠𝖬𝖤𝖶𝖮𝖱𝖪  © 𝟮𝟬𝟭𝟯 𝖠𝖫𝖤𝖷 𝖦𝖱𝖠𝖸  𝗀𝗂𝗍𝗁𝗎𝖻.𝖼𝗈𝗆/𝗺𝗿𝗮𝗹𝗲𝘅𝗴𝗿𝗮𝘆 */

#import "NSObject+StrictProtocols.h"
#import <objc/Protocol.h>

#define CLASS_STRING  NSStringFromClass([self class])

static NSMutableDictionary *conformanceCache = nil;
static NSUInteger methodCountForProtocol(Protocol*prtcl, BOOL optional)	{
	unsigned int  outCt = 0;	protocol_copyMethodDescriptionList(prtcl,!optional,YES,&outCt); return (NSUInteger)outCt;
}

@implementation NSObject (StrictProtocols)
+ (NSDictionary*) cachedConformance 									{ return conformanceCache[CLASS_STRING]; }
- 			  (BOOL) isaProtocol 											{

	const char * name = protocol_getName((Protocol*)self) ?: NULL;
	return name == NULL ? NO : objc_getProtocol(name) == ((Protocol*)self);
}
- 	  		  (BOOL) implementsProtocol:		(id)nameOrProtocol 	{ return [self.class implementsProtocol:nameOrProtocol optionalToo:NO]; }
- 	   	  (BOOL) implementsFullProtocol:	(id)nameOrProtocol 	{ return [self.class implementsProtocol:nameOrProtocol optionalToo:YES]; }
+ 		     (BOOL) implementsProtocol: 		(id)nameOrProtocol 	{ return [self implementsProtocol:nameOrProtocol optionalToo:NO]; }
+ 	        (BOOL) implementsFullProtocol:	(id)nameOrProtocol 	{ return [self implementsProtocol:nameOrProtocol optionalToo:YES]; }
+ 	   	  (BOOL) implementsProtocol:		(id)nameOrProtocol
								 optionalToo:		(BOOL)opt				{									// private
	
	Protocol *proto	= ((NSObject*)nameOrProtocol).isaProtocol ? nameOrProtocol				// did we pass in a string or a protocol?
	            		: [nameOrProtocol isKindOfClass:NSString.class]
							? NSProtocolFromString(nameOrProtocol) : NULL;
	if (proto == NULL) return NSLog(@"Can't determine protocol:%@", nameOrProtocol), NO;  	// Bail if clueless.
	NSString * pStr 	= NSStringFromProtocol(proto);													// Stringify protocol.
	if (opt)   pStr 	= [pStr stringByAppendingString:@"+optional"];								// differentiate @required vs @optional
	conformanceCache 	= conformanceCache ?: NSMutableDictionary.new;								// Get cache or create entry for class.
	__block NSNumber * conforms = conformanceCache[CLASS_STRING][pStr] ?: nil;					// Check for cached entry;
	if (conforms) return NSLog(@"%@ cached conformance to <%@> : %@",
		CLASS_STRING, pStr, conforms.boolValue ? @"YES" : @"NO"), conforms.boolValue;			// Return cached value.
	else conforms = @YES;																						// Logic start. Assume conformance.
	void (^testConformance)(BOOL) = ^(BOOL optional) { unsigned int  outCt = 0;				// Block takes single BOOL argument (@optional?).
		struct objc_method_description * methods
		=	protocol_copyMethodDescriptionList( proto, !optional, YES, &outCt) ?: NULL;  		// get @required, or @optional, dependent.
		for (int i = 0; i < outCt; ++i)																		// Iterate protocol methods.
      	if(!class_getInstanceMethod(self, methods[i].name)) { conforms = @NO; break; }   // Bail on any non-implementation
	   !methods ?: free(methods);      		 methods = NULL;											// Housekeeping
	};
	testConformance( NO); if (opt) testConformance(YES);												// if checking @optional, run block with YES;
#ifdef DEBUG
	NSLog(@"Caching %@ <%@> conformance for %@: %@\n@required: #%i\n@optional: #%i",
			opt ? @"@optional" : @"@required", pStr, CLASS_STRING, conforms.boolValue ? @"YES" : @"NO",
			methodCountForProtocol(proto,YES), methodCountForProtocol(proto, NO));				// optional:  count your methods.
#endif
	 conformanceCache[CLASS_STRING] =
	[conformanceCache[CLASS_STRING] ?: @{} dictionaryBySettingValue:conforms forKey:pStr];
	return conforms.boolValue;																					// Set cach and return.
}		@end
#define 	TEST
#ifdef 	TEST
#import <XCTest/XCTest.h>
@protocol        		StrictProtocol - (void) unspecifiedMethod;
@required								  	- (void)    requiredMethod;
@optional 							     	- (void)    optionalMethod;			@end
@interface 		 NonComformantObject : NSObject <StrictProtocol>			@end
@interface 		SemiComformantObject : NSObject <StrictProtocol>			@end
@interface	   	 ConformantObject : NSObject <StrictProtocol>			@end
@interface	     InheritedConformer : ConformantObject						@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation  NonComformantObject												@end
@implementation SemiComformantObject - (void)    requiredMethod	{	}
												 - (void) unspecifiedMethod 	{	}	@end
#pragma clang diagnostic pop
@implementation   InheritedConformer												@end
@implementation     ConformantObject - (void)    requiredMethod 	{	}
												 - (void)    optionalMethod 	{	}
												 - (void) unspecifiedMethod	{	}	@end
@interface 		  StrictProtocolTests : XCTestCase 						{	Protocol *proto;
NonComformantObject * non; SemiComformantObject * semi;
ConformantObject * strict; InheritedConformer  * child; 	}	@end
@implementation  StrictProtocolTests - (void) 	 			 setUp	{   [super setUp]; proto = @protocol(StrictProtocol);
	non = NonComformantObject.new; semi = SemiComformantObject.new; strict = ConformantObject.new; child = InheritedConformer.new;
}
- (void)  testConformanceCaching	{ BOOL itDoes;
	XCTAssert		([strict.class cachedConformance].allKeys.count == 0);
			itDoes =	[strict 	implementsProtocol:proto];
	XCTAssert		([strict.class cachedConformance].allKeys.count == 1);
			itDoes =	[strict 	implementsFullProtocol:proto];
	XCTAssert		([strict.class cachedConformance].allKeys.count == 2);
	NSLog(@"%@",[strict.class cachedConformance]);
}
- (void) testRequiredConformance	{
	XCTAssertFalse	([non    implementsProtocol:proto], @"non	 	SHOULD NOT conform to the @required protocol");
	XCTAssert		([child  implementsProtocol:proto], @"child  SHOULD conform to the @required protocol");
	XCTAssert		([semi   implementsProtocol:proto], @"semi   SHOULD conform to the @required protocol");
	XCTAssert		([strict implementsProtocol:proto], @"strict SHOULD conform to the @required protocol");
}
- (void) testOptionalConformance	{
	XCTAssertFalse	([non    implementsFullProtocol:proto], @"non    SHOULD NOT conform to the @optional protocol");
	XCTAssert		([child  implementsFullProtocol:proto], @"child  SHOULD conform to the @optional  protocol");
	XCTAssertFalse	([semi 	implementsFullProtocol:proto], @"semi   SHOULD NOT conform to the @optional protocol");
	XCTAssert		([strict implementsFullProtocol:proto], @"strict SHOULD conform to the @optional protocol");
}												@end
#endif

