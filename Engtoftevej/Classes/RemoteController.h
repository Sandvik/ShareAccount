//
//  RemoteController.h
//  PicsLic
//
//  Created by Thomas H. Sandvik on 4/14/12.
//  Copyright (c) 2012 Sandvik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartPhoneResponseFactory.h"
#import "GTMHTTPFetcher.h"

@class RemoteController;

@protocol RemoteControllerDelegate 

@optional
-(void) remoteController:(RemoteController *)controller overviewResponse:(ProductOverviewResponse *)response errorMessage:(NSString *)errorMessage;

@end;

@interface RemoteController : NSObject <RemoteControllerDelegate> {
	id <RemoteControllerDelegate, NSObject> delegate;
    
	int fetchCount;
    NSString *regnskabsnavn;
}

@property (nonatomic, retain) id <RemoteControllerDelegate> delegate;
@property (nonatomic, retain) NSString *regnskabsnavn;
//-(void) callOverview;
-(void) getCurrentUser:(NSString*)email;
-(void) getForretningList;
-(void) callOverview:(NSInteger)regnskabsid;

-(void)insertPersonValue:(NSString*)username password:(NSString*)password email:(NSString*)emailAdresse fuldtNavn:(NSString*)fuldtNavn;

-(void)createRegnskab:(NSString*)regnskab;
-(void)deleteRegnskab:(NSInteger)ident;
-(void)deleteRegnskabAssociation:(NSInteger)regnskabident;
-(void)deleteFileFromServer:(NSInteger)file2Delete;
-(void)insertPostValue:(NSString*)person type:(NSString*)type pris:(NSString*)pris kvittering:(NSData *)kvittering postnote:(NSString *)postnote;
-(BOOL) isValidJsonResponseFromFetcher:(GTMHTTPFetcher *)fetcher data:(NSData *)data caller:(NSString*)caller;
-(void)deleteValue:(NSInteger)ident;
-(void) responseFromFetcher:(GTMHTTPFetcher *)fetcher data:(NSData *)data;
       
-(void)updateRegnskab:(NSDate*)fraDato tildato:(NSDate*)tildato regnskab:(NSString*)regnskab status:(NSString*)status;
@end
