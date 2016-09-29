//
//  ExternalAccount.h
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 3/8/11.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NYKGeneralAccount : NSObject {
@private 
	NSString *type;
    NSString *objectName;
    NSString *afstemtJN;
    NSDecimalNumber *price;
    NSDecimalNumber *tilgode;

    NSDate *transactionDate;
    NSInteger ident;
    NSInteger personIdent;
    NSString *email;
    NSString *postnote;
    double fordeling;
}
@property (nonatomic, copy) NSString *postnote;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *objectName;
@property (nonatomic, copy) NSString *afstemtJN;
@property (nonatomic,retain) NSDecimalNumber *price;
@property (nonatomic,retain) NSDecimalNumber *tilgode;
@property (nonatomic,retain) NSDate *transactionDate;
@property (assign) NSInteger ident;
@property(nonatomic) double fordeling;
@property (assign) NSInteger personIdent;
@end
