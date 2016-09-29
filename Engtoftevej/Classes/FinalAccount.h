//
//  ExternalAccount.h
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 3/8/11.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FinalAccount : NSObject {
@private 
	NSString *navn;
    NSString *afstemtJN;
    NSDecimalNumber *ialtbrugt;
    
    NSDate *startDato;
    NSDate *slutDato;
   
    NSMutableArray *accounts;
}
@property (nonatomic, copy) NSMutableArray *accounts;
@property (nonatomic, copy) NSString *navn;
@property (nonatomic, copy) NSString *afstemtJN;
@property (nonatomic,retain) NSDecimalNumber *ialtBrugt;
@property (nonatomic,retain) NSDate *startDato;

@property (nonatomic,retain) NSDate *slutDato;

@end
