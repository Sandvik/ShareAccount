#import <Foundation/Foundation.h>
#import "NYKGeneralAccount.h"

@interface NYKAccount : NYKGeneralAccount {
@private 
	NSDecimalNumber *balance;
	BOOL fromTransferAllowed;
	BOOL toTransferAllowed;
    BOOL spendingOverviewAvailable;
    NSString *spendingLink;
    NSString *currency;
}
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *spendingLink;
@property (nonatomic, retain) NSDecimalNumber *balance;
@property (nonatomic) BOOL fromTransferAllowed;
@property (nonatomic) BOOL toTransferAllowed;
@property (nonatomic) BOOL spendingOverviewAvailable;

@end
