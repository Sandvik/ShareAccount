//
//  ExternalAccount.m
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 3/8/11.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import "NYKGeneralAccount.h"
   

@implementation NYKGeneralAccount
@synthesize objectName;
@synthesize afstemtJN;
@synthesize type;
@synthesize price,tilgode;
@synthesize transactionDate;
@synthesize ident,fordeling,personIdent;
@synthesize email,postnote;


-(NSString*) description {
	return [NSString stringWithFormat:@"type:%@, price#%@, transactionsdate:%@, Person:%@, Afstemt:%@, skalBetale:%@ ident:%d email:%@ postnote:%@ fordeling:%.2f personIdent:%d" , 
			type,price,transactionDate,objectName,afstemtJN,tilgode,ident,email,postnote,fordeling,personIdent];
}

- (void) dealloc {
	[type release];
    [postnote release];
    [email release];
    [objectName release];
    [afstemtJN release];
	[price release];
    [tilgode release];
    [transactionDate release];
	[super dealloc];
}
@end
