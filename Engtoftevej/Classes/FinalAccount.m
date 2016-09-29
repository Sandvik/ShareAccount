//
//  ExternalAccount.m
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 3/8/11.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import "FinalAccount.h"
   

@implementation FinalAccount

@synthesize afstemtJN;
@synthesize navn;
@synthesize ialtBrugt;
@synthesize startDato,slutDato;

@synthesize accounts;


-(NSString*) description {
	return [NSString stringWithFormat:@"accounts:%@,", 
			accounts];
}

- (void) dealloc {
	[navn release];
  
    [afstemtJN release];
	[ialtBrugt release];
    
    [startDato release];
    [slutDato release];
	[super dealloc];
}
@end
