//
//  RemoteServiceStatus.m
//  MitNykredit
//
//  Created by Wojciech Chojnacki on 12/10/10.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import "RemoteServiceStatus.h"


@implementation RemoteServiceStatus
@synthesize authorized;
@synthesize envelopeSystem;
@synthesize customer;
@synthesize urlLocationLogOut;
@synthesize authenticationLevel;

static RemoteServiceStatus *sharedStatus = nil;

+ (RemoteServiceStatus *)sharedStatus {
    @synchronized(self) {
        if(sharedStatus == nil) {
            sharedStatus = [[self alloc] init];
		}
    }
    return sharedStatus;
}

-(id) init {
	if( (self = [super init]) ){
		self.authorized = FALSE;
        self.envelopeSystem =@"";//Initialize envelopSystem to empty string
        self.customer =@"";//Initialize customer to empty string
        self.urlLocationLogOut =@"";//Initialize urllocation to empty string
        self.authenticationLevel=0;
	}
	return self;
}

- (BOOL)isOutTrayEvenlopeEnabled {
     return [self.envelopeSystem caseInsensitiveCompare:@"outtray"] == NSOrderedSame;  
}


- (BOOL)isauthenticationLevel20_OR_15 {
    return (authenticationLevel == 20 || authenticationLevel == 15);  
}

-(void)dealloc{
    self.envelopeSystem = nil;
    self.customer = nil;
    self.urlLocationLogOut = nil;
    [super dealloc];
}
@end
