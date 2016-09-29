//
//  NYKOverView.m
//  MitNykredit
//
//  Created by Thomas Sandvik on 2/10/11.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import "NYKOverView.h"


@implementation NYKOverView

@synthesize name, overviewNumber,type,balance,marketValue,currency,insuranceType,insurancePremium;


-(NSString*) description {
	return [NSString stringWithFormat:@"[Overview name:%@ number#%@ type:%@ balance:%@ marketValue:%@ currency:%@ insuranceType:%@, insurancePremium%@]", 
			name, overviewNumber,type,balance,marketValue,currency,insuranceType,insurancePremium];
}

- (void) dealloc {
	[name release];
	[overviewNumber release];
	[type release];
	[balance release];	
	[marketValue release];	
	[currency release];
    [insurancePremium release];
	[insuranceType release];
	[super dealloc];
}
@end
