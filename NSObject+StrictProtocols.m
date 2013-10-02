
/**  NSObject+StrictProtocols.m  *//* 𝘗𝘈𝘙𝘛 𝘖𝘍 𝗔𝖳𝖮𝗭.𝖥𝖱𝖠𝖬𝖤𝖶𝖮𝖱𝖪  © 𝟮𝟬𝟭𝟯 𝖠𝖫𝖤𝖷 𝖦𝖱𝖠𝖸  𝗀𝗂𝗍𝗁𝗎𝖻.𝖼𝗈𝗆/𝗺𝗿𝗮𝗹𝗲𝘅𝗴𝗿𝗮𝘆 */

#import "NSObject+StrictProtocols.h"

#define CLASS_STRING  NSStringFromClass([self class])

static NSMutableDictionary *conformanceCache = nil;


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

+ 	   	  (BOOL) implementsProtocol:		(id)nameOrProtocol optionalToo:(BOOL)opt {		// private
	
	conformanceCache 	= conformanceCache ?: NSMutableDictionary.new;								// retrieve or init cache
	Protocol *proto 	= ((NSObject*)nameOrProtocol).isaProtocol
							? nameOrProtocol  																	// did we pass in a string or a protocol?
	            		: [nameOrProtocol isKindOfClass:NSString.class]
							? NSProtocolFromString(nameOrProtocol) : NULL;

	if (proto == NULL) return NSLog(@"Can't determine protocol:%@", nameOrProtocol), NO;  // Bail if clueless.

	NSString  			  * pString = opt																		// Use the "Protocol" or "Protocol+optional"
											? [NSStringFromProtocol(proto) withString: @"+optional"] // string as out cached lookup key.
											: NSStringFromProtocol(proto);									// Allows cached/seperate values for each.

	NSMutableDictionary * clsInfo = conformanceCache[CLASS_STRING]
											?: NSMutableDictionary.new;     									// Get cache or create entry for class.

	__block NSNumber  * conforms = [clsInfo objectForKey:pString] ?: nil;						// Check for cached entry;
	if (conforms)																									// If already cached
		return NSLog(@"returning cached conformance to:<%@> for class:%@ ... %@",
								pString, CLASS_STRING, conforms.boolValue ? @"YES" : @"NO"),		// Log about it.
				 conforms.boolValue;																				// Return cached value.
	else conforms = @YES;																						// Logic start. Assume conformance.

	__block int totalMethods = 0, optionalMethods = 0;													// optional:  count your methods.

	void (^testConformance)(BOOL) = ^(BOOL optionalOpt){												// setup testing block
								unsigned int  outCount = 0;													// Block takes single BOOL argument.
		struct objc_method_description * methods
		=	protocol_copyMethodDescriptionList( proto, !optionalOpt, YES, &outCount)         // get @required, or @optional, dependent.
		?: NULL;

 		totalMethods += outCount; if (optionalOpt) optionalMethods = outCount;					// Set our method counters.
		for (unsigned int i = 0; i < outCount; ++i)														// Iterate protocol methods.
      	if(!class_getInstanceMethod(self, methods[i].name)) { conforms = @NO; break; }   // Bail on any non-implementation
	   if (methods) free(methods); 		methods = NULL;												// Housekeeping
	};
	if (opt) testConformance(YES);																			// if checking @optional, run block with YES;
				testConformance( NO);																			// Always run block with NO.

	NSLog(@"Caching <%@> conformance for %@: %@\n@required: #%i\n@optional: #%i",
							   opt ? @"@optional" : @"required", pString, CLASS_STRING,				// Log results.
	      conforms.boolValue ? @"YES" : @"NO",    totalMethods, optionalMethods);

	return [(conformanceCache[CLASS_STRING][pString] = conforms) boolValue];					// Set cach and return.
}

@end

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
@implementation SemiComformantObject - (void)    requiredMethod	{}		@end
#pragma clang diagnostic pop
@implementation   InheritedConformer												@end
@implementation     ConformantObject - (void)    requiredMethod 	{}
												 - (void)    optionalMethod 	{}
												 - (void) unspecifiedMethod 	{}		@end

@interface 		  StrictProtocolTests : XCTestCase @property Protocol *proto;
@property	     NonComformantObject * non;
@property	    SemiComformantObject * semi;
@property	        ConformantObject * strict;
@property	      InheritedConformer * child;
@end
@implementation  StrictProtocolTests

- (void)setUp		{   [super setUp]; _proto = @protocol(StrictProtocol);
	_non = NonComformantObject.new; _semi = SemiComformantObject.new; _strict = ConformantObject.new;  _child = InheritedConformer.new; }

- (void)tearDown	{    [super tearDown];	}

- (void)testUnimplementedRequiredMethod	{
	XCTAssert(![_non  implementsProtocol:_proto], @"non must not conform");
}
- (void)testImplementedRequiredMethod	{
	XCTAssert( [_child implementsProtocol:_proto], @"semi must not conform");
	XCTAssert( [_semi implementsProtocol:_proto], @"semi must not conform");
	XCTAssert( [_strict implementsProtocol:_proto], @"strict must conform");
//	XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
- (void)testUnimplementedOptionalMethod
{
	XCTAssert(![_non  implementsProtocol:_proto], @"non must not conform");
	XCTAssert( [_child implementsProtocol:_proto], @"semi must not conform");
	XCTAssert( [_semi implementsProtocol:_proto], @"semi must not conform");
	XCTAssert([_strict implementsProtocol:_proto], @"strict must conform");
//	XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}


@end

#endif

