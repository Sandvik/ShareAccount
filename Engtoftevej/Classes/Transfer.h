//
//  PendingTransaction.h
//  MitNykredit
//
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYKAccount.h"

@interface Transfer : NSObject {
	NYKAccount *fromAccount;
	NYKGeneralAccount *toAccount;

	NSDecimalNumber *amount;
   	NSString *fromMessage;
    NSString *transferType;
	NSString *toMessage;
	NSDate *transactionDate;
    NSString *envelopeItemId;
    NSInteger outtrayVersion;
    BOOL isAnUpdate;
    BOOL directlyToOuttray;
    BOOL isMobileTransferOrPayment;
}
@property (nonatomic) BOOL isAnUpdate;
@property (nonatomic) BOOL directlyToOuttray;
@property (nonatomic) BOOL isMobileTransferOrPayment;
@property (nonatomic,retain) NYKAccount *fromAccount;
@property (nonatomic,retain) NYKGeneralAccount *toAccount;
@property (nonatomic,retain) NSDecimalNumber *amount;
@property (nonatomic,copy) NSString *fromMessage;
@property (nonatomic,copy) NSString *transferType;
@property (nonatomic) NSInteger outtrayVersion;
@property (nonatomic,copy) NSString *toMessage;
@property (nonatomic,retain) NSDate *transactionDate;
@property (nonatomic,copy) NSString *envelopeItemId;//Optional: Only needed when object should be deleted


- (BOOL) isValid;

@end
