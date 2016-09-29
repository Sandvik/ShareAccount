//
//  SmartPhoneResponse.h
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/6/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SmartPhoneResponseStatusOK = 1, //ok
	SmartPhoneResponseStatusERROR = 2, //validation error
	SmartPhoneResponseStatusSESSION_INVALID = 4, //user session invalid, user should be logout
	SmartPhoneResponseStatusUNKNOW = 0,
    SmartPhoneResponseStatusPROTOCOLNOTSUPPORTED = 5, //Protocol version invalid, user should be logout
    SmartPhoneResponseStatusOKOLDPROTOCOL = 6 //Protocol version invalid, user should be logout
} SmartPhoneResponseStatus;

@interface SmartPhoneResponse : NSObject {
	SmartPhoneResponseStatus status;
	NSArray *messages;
    NSString *envelopeSystem;
    NSString *customer;
    NSInteger authenticationLevel;
}

@property (nonatomic) SmartPhoneResponseStatus status;
@property (nonatomic, copy) NSString *envelopeSystem;
@property (nonatomic, copy) NSString *customer;
@property (nonatomic) NSInteger authenticationLevel;
@property (nonatomic, copy) NSArray *messages;
@end
