//
//  RemoteServiceStatus.h
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/10/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RemoteServiceStatus : NSObject {
	
@private
	BOOL authorized;
    NSString *envelopeSystem;
    NSString *customer;
    NSString *urlLocationLogOut;
    NSInteger authenticationLevel;
}
@property (nonatomic, copy) NSString *envelopeSystem;
@property (nonatomic, copy) NSString *urlLocationLogOut;
@property (nonatomic, copy) NSString *customer;
@property (nonatomic) NSInteger authenticationLevel;
@property (nonatomic) BOOL authorized;


//singleton 
+ (RemoteServiceStatus *)sharedStatus;
- (BOOL)isOutTrayEvenlopeEnabled;
- (BOOL)isauthenticationLevel20_OR_15; 
@end
