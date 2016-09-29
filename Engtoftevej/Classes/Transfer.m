//
//  PendingTransaction.m
//  MitNykredit
//
//  Copyright 2010 Nykredit. All rights reserved.
//

#import "Transfer.h"
#import "NYKAccount.h"
#import "NYKExternalAccount.h"

@implementation Transfer

@synthesize fromAccount;
@synthesize toAccount;
@synthesize amount;
@synthesize outtrayVersion;
@synthesize fromMessage;
@synthesize toMessage;
@synthesize transactionDate;
@synthesize envelopeItemId;
@synthesize isAnUpdate,directlyToOuttray,isMobileTransferOrPayment;
@synthesize transferType;

-(NSString *) description {
	return [NSString stringWithFormat:@"From Account: %@\nTo Account: %@\nAmount: %@\nDate: %@\nTo Message: %@\nFrom Message: %@\nEnvelopeID: %@ outtrayVersion: %d transferType: %@", fromAccount, toAccount, amount, transactionDate, toMessage, fromMessage, envelopeItemId,outtrayVersion,transferType];
}

- (BOOL) isValid {
       if (fromAccount != nil && toAccount != nil && amount != nil && transactionDate != nil) {
		return YES;
	}
	return NO;
}

- (void) dealloc {
	[fromAccount release];
	[toAccount release];
    [transferType release];
	[amount release];
	[transactionDate release];
    
	[super dealloc];
}

@end
