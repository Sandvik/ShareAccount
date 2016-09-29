//
//  Account.m
//  
//
//  Created by chojnac on 10-09-27.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import "NYKAccount.h"


@implementation NYKAccount
@synthesize  balance, fromTransferAllowed, toTransferAllowed,spendingOverviewAvailable,spendingLink,currency;


-(NSString*) description {
	return [NSString stringWithFormat:@"[Account name:%@ number#%@ saldo:%@ fromTransferAllowed=%d toTransferAllowed=%d spendingOverviewAvailable=%d spendingLink=%@ currency=%@]", 
			self.name, self.number, balance, fromTransferAllowed, toTransferAllowed,spendingOverviewAvailable,spendingLink,currency];
}

- (void) dealloc {
	[balance release];
    [spendingLink release];
    [currency release];
	[super dealloc];
}
@end
