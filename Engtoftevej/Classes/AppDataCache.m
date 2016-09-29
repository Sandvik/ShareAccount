//
//  AppDataSource.m
//  MitNykredit
//
//  Created by chojnac on 10-09-27.
//  Copyright 2010 Nykredit. All rights reserved.
//

#import "AppDataCache.h"


NSString* const kAppDataCacheChangeAccountsNotification = @"kAppDataCacheChangeAccountsNotification";
NSString* const kAppDataCacheLogonRestStatusCode = @"kAppDataCacheLogonRestStatusCode";
NSString* const kAppDataCacheSpendingOverviewStatusCode = @"kAppDataCacheSpendingOverviewStatusCode";
NSString* const kAppDataCacheMoveSpendingStatusCode = @"kAppDataCacheMoveSpendingStatusCode";
NSString* const kAppDataCacheLogoutStatusCode = @"kAppDataCacheLogoutStatusCode";
NSString* const kAppDataCacheListStoredTransfersStatusCode = @"kAppDataCacheListStoredTransfersStatusCode";
NSString* const kAppDataCacheReadStoredPaymentStatusCode = @"kAppDataCacheReadStoredPaymentStatusCode";

@implementation AppDataCache

@synthesize accounts,personsPaymentList,peopleList,forretningList,finishedAccountings,custodyLines,mortgages,overview,mitNykreditTvFeed,mitNykreditNewsFeed,spendingOverviewAll,spendingOverviewAllYearAgo,monthOffset,monthOffsetYearAgo, menuListItems;
@synthesize currentRegnskabsID,currentUserId,currentPostId;
//@synthesize currentAccountWorkingWith;
@synthesize currentCategoryId,currentUsername,currencyCallerorigin,currentRegnskabsNavn,regnskabsAfregnesLigeEllerUlige;
@synthesize isRestCommunication,reloadOverviewRequired,isOnline,recievedSamlResponse,loggedInViaNemID;
@synthesize baseURL,baseRestURL;
@synthesize cookies, customer;
@synthesize posteringerNumbersList;

static AppDataCache *sharedAppDataSource;

+ (AppDataCache *)sharedAppDataSource{
	@synchronized(self) {
		if(sharedAppDataSource==nil) {
			sharedAppDataSource = [[AppDataCache alloc] init];
		}
	}
	return sharedAppDataSource;
}


- (id) init{
	if( self == [super init] ){
        peopleList=[[NSMutableArray alloc] init];
        menuListItems=[[NSMutableArray alloc] init];
		accounts = [[NSMutableArray alloc] init];
        personsPaymentList =[[NSMutableArray alloc] init];
        posteringerNumbersList =[[NSMutableArray alloc] init];
		forretningList = [[NSMutableArray alloc] init];
        mortgages = [[NSMutableArray alloc] init];
		overview = [[NSMutableArray alloc] init];
        custodyLines = [[NSMutableArray alloc] init];
		mitNykreditTvFeed = [[NSMutableArray alloc] init];
        finishedAccountings =[[NSMutableArray alloc] init];
        spendingOverviewAllYearAgo=[[NSMutableArray alloc] init];
        spendingOverviewAll =[[NSMutableArray alloc] init];
        currentRegnskabsID=0;
        currentUserId=0;
        currentPostId=0;
        monthOffset=3; //default for offset 
        monthOffsetYearAgo=-12;//the period we compare spending to -- this variable is different in test SEE:NYKRootViewController
        //currentSpendingWorkingWith = [[NYKGeneralSpendingOverview alloc] init];
        //currentAccountWorkingWith = [[NYKAccount alloc] init];
        currentCategoryId = [[NSString alloc] init];
        currentUsername = [[NSString alloc] init];
        currentRegnskabsNavn = [[NSString alloc] init];
        regnskabsAfregnesLigeEllerUlige=[[NSString alloc] init];
        currencyCallerorigin = [[NSString alloc] init];        
        baseRestURL =[[NSString alloc] init];
        baseURL=[[NSString alloc] init];
        cookies=[[NSArray alloc] init];
	}	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	//DLog(@"cache changed ");
    if ([keyPath isEqual:@"accounts"]) {
		//DLog(@"accounts changed, reload table ");
		[[NSNotificationCenter defaultCenter] postNotificationName:kAppDataCacheChangeAccountsNotification object:nil userInfo:nil];
	}
}

-(void) accountsChanged:(id)source {
	//DLog(@"accounts changed ");
	[[NSNotificationCenter defaultCenter] postNotificationName:kAppDataCacheChangeAccountsNotification object:nil userInfo:nil];
}


#pragma mark -
#pragma mark Application's documents directory - Core Data related

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (void) dealloc
{
	[posteringerNumbersList release];
    [personsPaymentList release];
	[accounts release];
    [peopleList release];
    [menuListItems release];
	[forretningList release];
    [mortgages release];
    [finishedAccountings release];
    [overview release];
	[mitNykreditTvFeed release];
	[mitNykreditNewsFeed release];
	[spendingOverviewAll release];
    [spendingOverviewAllYearAgo release];
	//[currentSpendingWorkingWith release];
    [regnskabsAfregnesLigeEllerUlige release];
    [currentCategoryId release];
    [currentUsername release];
    [currentRegnskabsNavn release];
    [currencyCallerorigin release];
    [baseURL release];
    [baseRestURL release]; 
    [cookies release];
	
	[super dealloc];
}
@end
