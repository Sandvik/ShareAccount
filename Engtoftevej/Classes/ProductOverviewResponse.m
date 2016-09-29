//
//  ProductOverviewResponse.m
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/7/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import "ProductOverviewResponse.h"


@implementation ProductOverviewResponse
@synthesize accounts;
@synthesize custodies;
@synthesize mortgages;
@synthesize overview;
@synthesize insurances;
@synthesize payments;



-(void)dealloc {
	[super dealloc];
	[accounts release];
	[custodies release];
	[overview release];
    [mortgages release];
    [insurances release];
    [payments release];

}
@end
