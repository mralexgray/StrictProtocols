
/**  NSObjectStrictProtocolTests.m  *//* 𝘗𝘈𝘙𝘛 𝘖𝘍 𝗔𝖳𝖮𝗭.𝖥𝖱𝖠𝖬𝖤𝖶𝖮𝖱𝖪  © 𝟮𝟬𝟭𝟯 𝖠𝖫𝖤𝖷 𝖦𝖱𝖠𝖸  𝗀𝗂𝗍𝗁𝗎𝖻.𝖼𝗈𝗆/𝗺𝗿𝗮𝗹𝗲𝘅𝗴𝗿𝗮𝘆 */

#import <XCTest/XCTest.h>
#import <objc/Protocol.h>
#import "NSObject+StrictProtocols.h"

                        #pragma mark - Test Protocol Definition
@protocol             StrictProtocol - (void) unspecifiedMethod;
@required                            - (void) requiredMethod;
@optional                            - (void) optionalMethod;        @end

                        #pragma mark        - Test Classes With Varying Conformance
@interface       NonComformantObject : NSObject <StrictProtocol>      @end
@interface      SemiComformantObject : NSObject <StrictProtocol>      @end
@interface          ConformantObject : NSObject <StrictProtocol>      @end
@interface        InheritedConformer : ConformantObject               @end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation  NonComformantObject                                  @end
@implementation SemiComformantObject - (void)    requiredMethod {   }
                                     - (void) unspecifiedMethod {   } @end
#pragma clang diagnostic pop
@implementation   InheritedConformer                                  @end
@implementation     ConformantObject - (void)    requiredMethod {   }
                                     - (void)    optionalMethod {   }
                                     - (void) unspecifiedMethod {   } @end

                          #pragma mark - Test Case
@interface        StrictProtocolsTests : XCTestCase             {
Protocol *proto;
NonComformantObject * non;  SemiComformantObject * semi;
ConformantObject * strict;  InheritedConformer  * child;            } @end

@implementation  StrictProtocolsTests - (void) setUp  {   [super setUp];

	proto  = @protocol(StrictProtocol);

	non    = NonComformantObject.new;   semi  = SemiComformantObject.new;
    strict = ConformantObject.new;      child = InheritedConformer.new;
}

- (void)  testConformanceCaching    { BOOL itDoes;                          //  Caching of previously fetched conformance
    XCTAssert       ([strict.class cachedConformance].allKeys.count == 0);  // count the keys, make sure they increment.
        itDoes =     [strict implementsProtocol:proto];
    XCTAssert       ([strict.class cachedConformance].allKeys.count == 1);
        itDoes =    [strict  implementsFullProtocol:proto];
    XCTAssert       ([strict.class cachedConformance].allKeys.count == 2); NSLog(@"%@",[strict.class cachedConformance]);
}
- (void) testRequiredConformance    {   //  Tests if @required methods are actually implemented.
    XCTAssertFalse  ([non    implementsProtocol:proto], @"non    SHOULD NOT conform to the @required protocol");
    XCTAssert       ([child  implementsProtocol:proto], @"child  SHOULD conform to the @required protocol");
    XCTAssert       ([semi   implementsProtocol:proto], @"semi   SHOULD conform to the @required protocol");
    XCTAssert       ([strict implementsProtocol:proto], @"strict SHOULD conform to the @required protocol");
}
- (void) testOptionalConformance    {	//  Tests various combinations of optional / required / implemented / not implmented.
    XCTAssertFalse  ([non    implementsFullProtocol:proto], @"non    SHOULD NOT conform to the @optional protocol");
    XCTAssert       ([child  implementsFullProtocol:proto], @"child  SHOULD conform to the @optional  protocol");
    XCTAssertFalse  ([semi   implementsFullProtocol:proto], @"semi   SHOULD NOT conform to the @optional protocol");
    XCTAssert       ([strict implementsFullProtocol:proto], @"strict SHOULD conform to the @optional protocol");
}

- (void) testIsAProtocol {

	Class 	 k = NSString.class;
	Protocol *p	= @protocol(NSTableViewDataSource);
	id      idP	= @protocol(NSObject);
	id      str = @"CanHazProtocol, Mami";
	
	XCTAssertFalse([k   isaProtocol], @"should be FALSE.. it's a class, NOT a protocol!");
	XCTAssertTrue ([p   isaProtocol], @"should be TRUE.. it's a protcol!");
	XCTAssertTrue ([idP isaProtocol], @"should be TRUE.. it's id, but it's still a protocol!");
	XCTAssertFalse([str isaProtocol], @"should be FALSE.. it's an object, NOT a protcol!");
}
@end

