//
//  TransferResponse.h
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/10/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartPhoneResponse.h"

@interface TransferResponse : SmartPhoneResponse {
	NSString *fromAccountNumber;
	NSDecimalNumber *fromAccountBalance;
	NSString *toAccountNumber;
	NSDecimalNumber *toAccountBalance;
    BOOL amountCovered;
}

@property (nonatomic, retain) NSString *fromAccountNumber;
@property (nonatomic, retain) NSDecimalNumber *fromAccountBalance;
@property (nonatomic, retain) NSString *toAccountNumber;
@property (nonatomic, retain) NSDecimalNumber *toAccountBalance;
@property (nonatomic) BOOL amountCovered;
@end
