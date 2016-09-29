//
//  SmartPhoneResponse.m
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/6/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import "SmartPhoneResponse.h"


@implementation SmartPhoneResponse
@synthesize status,messages,envelopeSystem,customer,authenticationLevel;


-(void)dealloc {
	[super dealloc];
	[messages release];
    [envelopeSystem release];
    [customer release];
 
}
@end
