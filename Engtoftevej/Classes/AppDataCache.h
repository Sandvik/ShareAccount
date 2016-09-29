//
//  AppDataSource.h
//  MitNykredit
//
//  Created by chojnac on 10-09-27.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//#import "KeychainItemWrapper.h"
@class NYKCustomer;

extern NSString* const kAppDataCacheChangeAccountsNotification;
extern NSString* const kAppDataCacheLogonRestStatusCode;
extern NSString* const kAppDataCacheSpendingOverviewStatusCode;
extern NSString* const kAppDataCacheMoveSpendingStatusCode;
extern NSString* const kAppDataCacheLogoutStatusCode;
extern NSString* const kAppDataCacheListStoredTransfersStatusCode;
extern NSString* const kAppDataCacheReadStoredPaymentStatusCode;


@interface AppDataCache : NSObject {
	NSMutableArray *personsPaymentList;
    NSMutableArray *posteringerNumbersList;
	NSMutableArray *accounts;
    NSMutableArray *peopleList;//payments and stuff from OutTray
	NSMutableArray *forretningList;
    NSMutableArray *finishedAccountings;
	NSMutableArray* overview;
    NSMutableArray* mortgages;
	NSMutableArray* custodyLines;
    NSMutableArray *mitNykreditTvFeed;
	NSMutableArray *mitNykreditNewsFeed;
    NSMutableArray *spendingOverviewAll;
    NSMutableArray *spendingOverviewAllYearAgo;
    NSMutableArray *menuListItems;
    NSInteger currentRegnskabsID;
	NSInteger currentUserId;
    NSString *currentUsername;
    NSString *currentRegnskabsNavn;
    NSString *regnskabsAfregnesLigeEllerUlige;
    NSInteger currentPostId;
    NSInteger monthOffset;
    //NYKGeneralSpendingOverview *currentSpendingWorkingWith;
    //NYKAccount *currentAccountWorkingWith;
	NSString *currentCategoryId;
    
    NSInteger monthOffsetYearAgo;
    BOOL isRestCommunication;
   
    NSString *currencyCallerorigin;
    BOOL reloadOverviewRequired;
    BOOL isOnline;
    NSString *baseURL;
    NSString *baseRestURL;
    NSArray *cookies;
    BOOL recievedSamlResponse;
    BOOL loggedInViaNemID;
}
@property (nonatomic) BOOL isOnline;
@property (nonatomic) BOOL loggedInViaNemID;
@property (nonatomic) BOOL recievedSamlResponse;
@property (nonatomic, retain) NSString *currentUsername;
@property (nonatomic, retain) NSString *currentRegnskabsNavn;
@property (nonatomic, retain) NSString *regnskabsAfregnesLigeEllerUlige;


@property (nonatomic, retain) NSString *currencyCallerorigin;

@property (nonatomic) BOOL isRestCommunication;
@property (nonatomic) BOOL reloadOverviewRequired;
@property (nonatomic,retain) NSMutableArray *spendingOverviewAll;
@property (nonatomic,retain) NSMutableArray *spendingOverviewAllYearAgo;
@property (nonatomic) NSInteger monthOffsetYearAgo;
@property (nonatomic) NSInteger currentRegnskabsID;
@property (nonatomic) NSInteger currentUserId;
@property (nonatomic) NSInteger currentPostId;



@property (nonatomic) NSInteger monthOffset; //Variable determining common offset when choosing period in SpendingOvetview
//@property (nonatomic,retain) NYKGeneralSpendingOverview *currentSpendingWorkingWith;/*Variable dertermining which spendingobj we are working with when reload of spendinOverview eg. movement of transactions*/
//@property (nonatomic,retain) NYKAccount *currentAccountWorkingWith;/*Variable dertermining which account we are working with when reload of spendinOverview eg. movement of transactions*/
@property (nonatomic,retain) NSString *currentCategoryId;/*Variable dertermining which CategoryId we are working with when reload of spendinOverview eg. movement of transactions*/
@property (nonatomic,retain) NSString *baseURL;
@property (nonatomic,retain) NSString *baseRestURL;
@property (nonatomic,retain) NSArray *cookies;
@property (nonatomic,retain) NYKCustomer *customer;
@property (nonatomic,retain) NSMutableArray *accounts;
@property (nonatomic,retain) NSMutableArray *personsPaymentList;
@property (nonatomic,retain) NSMutableArray *posteringerNumbersList;



@property (nonatomic,retain) NSArray *menuListItems;
@property (nonatomic,retain) NSMutableArray *peopleList;
@property (nonatomic,retain) NSMutableArray *forretningList;
@property (nonatomic,retain) NSArray *finishedAccountings;

@property (nonatomic,retain) NSArray *mortgages;
@property (nonatomic,retain) NSArray *overview;
@property (nonatomic,retain) NSArray *custodyLines;

@property (nonatomic,retain) NSMutableArray *mitNykreditTvFeed;
@property (nonatomic,retain) NSMutableArray *mitNykreditNewsFeed;

+ (AppDataCache *)sharedAppDataSource;
-(void) accountsChanged:(id)source ;

/**
 * @return NO if xml feed empty 
 */
//- (BOOL) loadMitNykreditTVFeed;
//- (BOOL) loadMitNykreditNewsFeed;
//- (void) deleteAllObjects: (NSString *) entityDescription withContext:(NSManagedObjectContext *)ctx;

//CoreData related
//- (void) getTextFeedDataFromDataBase: (NSString *)desc sortingId:(NSString *)ident;
//- (void) getTvFeedDataFromDataBase: (NSString *)desc sortingId:(NSString *)ident;

//- (NSMutableArray *) fetchAndExecuteEvents: (NSString *)desc sortingId:(NSString *)ident;

@end
