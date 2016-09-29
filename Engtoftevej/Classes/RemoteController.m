//
//  RemoteController.m
//  PicsLic
//
//  Created by Thomas H. Sandvik on 4/14/12.
//  Copyright (c) 2012 Sandvik. All rights reserved.
//

#import "RemoteController.h"
#import "AppDataCache.h"
#import "Utilities.h"
#import "JSON.h"
#import "NIDBase64.h"
#import "SESpringBoard.h"
#import "BrowseViewController.h"
@implementation RemoteController

@synthesize delegate;
@synthesize regnskabsnavn;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Init our URLS diff if in DEBUG than i PROD
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
-(id) init {
	if( (self=[super init]) ){
        
		fetchCount = 0;
	}
	return self;
} 

-(void)deleteRegnskab:(NSInteger)ident{
  //NSLog(@"deleter %d",ident);
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/deleteRegnskab.php?ident='%d'",ident];
    [urlStr appendString:mytmp];
    
    //NSLog(@"%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(deleteRegnskabValue:finishedWithData:error:)];
}

-(void)deleteRegnskabAssociation:(NSInteger)regnskabident{
    //NSLog(@"deleter %d",regnskabident);
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/deleteRegnskabAssociationForPerson.php?regnskabident='%d'&personident='%d'",regnskabident,[AppDataCache sharedAppDataSource].currentUserId];
    [urlStr appendString:mytmp];
    
    //NSLog(@"%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(deleteValue:finishedWithData:error:)];
}

-(void)deleteRegnskabsEntry:(NSInteger)ident{
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/deleteEntry.php?ident='%d'",ident];
    [urlStr appendString:mytmp];
    
    //NSLog(@"%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(deleteValue:finishedWithData:error:)];
}

-(void)deleteValue:(NSInteger)ident{
    [AppDataCache sharedAppDataSource].currentPostId =ident;
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
     
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/deleteEntry.php?ident='%d'",ident];
    [urlStr appendString:mytmp];
    
    NSLog(@"%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(deleteValue:finishedWithData:error:)];
}
-(void)deleteRegnskabValue:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    fetchCount--;
    if(fetchCount==0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if (error != nil) {
        // Do your error handling logic
        
        NSString *msg = NSLocalizedString(@"Connection Error",
                                          @"The application encountered a connection error, please try again.");
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }
    else {
        //Delete alle imagefiler fra uploadsFolder der er associeret til de posteringer der er blevet slettet
        //DVs finde alle posteringer til regnskab
        [[AppDataCache sharedAppDataSource] posteringerNumbersList]; //alle posteringer til dem som skal slettes
        
        for(int i=0;i<[[[AppDataCache sharedAppDataSource] posteringerNumbersList] count];i++){
            NSNumber *identen =[[AppDataCache sharedAppDataSource].posteringerNumbersList objectAtIndex:i];
            NSLog(@"%d",[identen integerValue]);
             [self deleteFileFromServer:[identen integerValue]];  ;
        }
    }    
}

-(void)deleteValue:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    fetchCount--;
    if(fetchCount==0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if (error != nil) {
        // Do your error handling logic
        
        NSString *msg = NSLocalizedString(@"Connection Error",
                                          @"The application encountered a connection error, please try again.");
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }
    else {
    //Delete fil fra uploadsFolder hvis den findes
        NSInteger tmp = [[AppDataCache sharedAppDataSource] currentPostId];
        [self deleteFileFromServer:tmp];
        [AppDataCache sharedAppDataSource].currentPostId=0;
    }
    
}
//Sletter foto fra server hvis det findes: Dvs d foto man kan have vedlagt sin postering
-(void)deleteFileFromServer:(NSInteger)file2Delete{
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    NSString* del =[NSString stringWithFormat:@"uploads/%d.png",file2Delete];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/deleterFile.php?file2Delete=%@",del];
    [urlStr appendString:mytmp];
    
    NSLog(@"%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(deleteFile:finishedWithData:error:)];
}

-(void)deleteFile:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    fetchCount--;
    if(fetchCount==0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if (error != nil) {
        // Do your error handling logic
        
        NSString *msg = NSLocalizedString(@"Connection Error",
                                          @"The application encountered a connection error, please try again.");
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }
    else {
        //Delete fil fra uploadsFolder hvis den findes
        
        
    }
    
}


-(void)insertPersonValue:(NSString*)username password:(NSString*)password email:(NSString*)emailAdresse fuldtNavn:(NSString*)fuldtNavn{
    
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
     //NSLog(@" fuldtNavn == %@",fuldtNavn);
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/insertPerson.php?person='%@'&email='%@'&password='%@'&fuldtnavn='%@'",[username stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[emailAdresse stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[password stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[username stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[fuldtNavn stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [urlStr appendString:mytmp];
    
    //NSLog(@"%@",urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //[request addValue:tmpData forHTTPHeaderField:@"photo"];
    //[request setValue:tmpData forHTTPHeaderField:@"QUERY_STRING"]; 
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(insertValue:finishedWithData:error:)];

    
}

-(void)insertPostValue:(NSString*)person type:(NSString*)type pris:(NSString*)pris kvittering:(NSData *)kvittering postnote:(NSString *)postnote{
    //NSString *tmpData = [NIDBase64 base64EncodedString:kvittering];
    NSLog(@"%@",postnote);
    
   
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    
    NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormatx setDateFormat:@"dd-MM-yyyy"];    
    
    
      
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/indexKlunse2.php?pris=%@&person='%@'&type='%@'&regnskabsid='%d'&personid='%d'&postnote='%@'",pris,[person stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[type stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[AppDataCache sharedAppDataSource].currentRegnskabsID,[AppDataCache sharedAppDataSource].currentUserId,[postnote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [urlStr appendString:mytmp];
    
    NSLog(@"%@",urlStr);
    
    //NSString *args = [NSString stringWithFormat:@"pris=%@&person='%@'&type='%@'&kvittering='%@'",pris,person,type,tmpData];        
    //NSString *postLength = [NSString stringWithFormat:@"%d", [tmpData length]];
    //NSData *imageData = UIImageJPEGRepresentation(@"btn-overlay.png", 90);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //[request addValue:tmpData forHTTPHeaderField:@"photo"];
    //[request setValue:tmpData forHTTPHeaderField:@"QUERY_STRING"]; 
    
     GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(insertValue:finishedWithData:error:)];


}
 
 -(void)createRegnskab:(NSString*)navn{
     //NSLog(@"%d",[AppDataCache sharedAppDataSource].currentUserId);
     regnskabsnavn =[navn mutableCopy];
     NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
     
     NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
     [dateFormatx setDateFormat:@"dd-MM-yyyy"];    
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     NSString *email= [userDefaults stringForKey:@"emailAdresse"];    
     NSString *usernavn= [userDefaults stringForKey:@"username"];   
     
     
     NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/createRegnskab.php?navn='%@'&personid='%d'&email='%@'&usernavn='%@'",[navn stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding ],[AppDataCache sharedAppDataSource].currentUserId,email,usernavn];
     [urlStr appendString:mytmp];

     //NSLog(@"%@",urlStr);
     NSURL *url = [NSURL URLWithString:urlStr];
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
     [request setHTTPMethod:@"POST"];
     [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
     [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
     [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
     [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
     [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
          
     GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
     
     fetchCount++;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(insertRegnskabsValue:finishedWithData:error:)];
      
 }
 
// [remoteController updateRegnskab:lastObj.transactionDate tilDato:firstObj.transactionDate regnskab:regnskab regnskabId: [AppDataCache sharedAppDataSource].currentRegnskabsID status:@"AFSLUT"];

-(void)updateRegnskab:(NSDate*)fraDato tildato:(NSDate*)tildato regnskab:(NSString*)regnskab status:(NSString*)status{
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    
    NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormatx setDateFormat:@"dd-MM-yyyy"];    
    NSString*fraDatoTmp= [dateFormatx stringFromDate:fraDato];
    NSString*tilDatoTmp= [dateFormatx stringFromDate:tildato];
    
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/insertRegnskab.php?fradato='%@'&tildato='%@'&regnskab='%@'&regnskabsid='%d'&status='%@'",fraDatoTmp,tilDatoTmp,[regnskab stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[AppDataCache sharedAppDataSource].currentRegnskabsID,status];
    [urlStr appendString:mytmp];
    
    //NSLog(@"%@",urlStr);
    
    //INSERT INTO engtoftevej_accounting (fraDato,tilDato,regnskab,regnskabsid,status) VALUES('14-06-2012','14-06-2012','Person:ThomasUd:1326.65%20Skylder:-755.675Person:CharlotteUd:2838%20Skylder:0','35','AFSLUTTET')
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(insertValue:finishedWithData:error:)];
    
}

 -(void)insertValue:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
     fetchCount--;
     if(fetchCount==0){
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }
     if(error!=nil)  {
         //NSLog(@"Error: %@",error);
         return;
     }
     
     [self responseFromFetcher:fetcher data:data];     
 }

-(void)insertRegnskabsValue:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    fetchCount--;
    if(fetchCount==0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if(error!=nil)  {
        //NSLog(@"Error: %@",error);
        return;
    }
    NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
    NSLog(@"SpendingData %@", jsonString);
    
    //NSLog(@"%@",regnskabsnavn);
    BrowseViewController *vc1 = [[BrowseViewController alloc] initWithNibName:@"BrowseView" bundle:nil];
    vc1.regnskabsid = [jsonString integerValue];
    SEMenuItem *gg = [SEMenuItem initWithTitle:regnskabsnavn imageName:@"cash-register-icon.png" viewController:vc1 removable:NO];
    
    [[SESpringBoard sharedSESpringBoard] add2FromSpringboard:gg];
    
    [self responseFromFetcher:fetcher data:data];     
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Call overview -Getting all data to create overview
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
-(void) callOverview:(NSInteger)regnskabsid{
    //    DLog(@"callOverview");    
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
	
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/indexKlunse.php?ident='%d'",regnskabsid];
    [urlStr appendString:mytmp];
    
    //NSLog(@"urlStr: %@",urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(callOverview:finishedWithData:error:)];
}

-(void)callOverview:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    fetchCount--;
    if(fetchCount==0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    //NYKResponseHeader *header =[self responseFromFetcher:fetcher data:data];
    
    //if(header.validStatus  && header.validJson){//All is good
    ProductOverviewResponse *response = [SmartPhoneResponseFactory overviewResponseFromJSon:data];
    response.status = SmartPhoneResponseStatusOK;
    [self remoteController:self overviewResponse:response errorMessage:nil];
    
    //return; //success
    //}
    
    // NSString *errMsg=nil;   
    //if(!header.validStatus  && !header.validJson){//Cant read json and status is not valid
    //Both Json and status i invalid
    
    //[self remoteController:self overviewResponse:nil errorMessage:NSLocalizedString(@"Connection Error", 
    //                                                                                       @"The application encountered a connection error, please try again.")
    //];
    //return;
    //}
    //else if(!header.validStatus  && header.validJson){//Cant read json and status is not valid -We read message
    //    if(header.message!=nil) errMsg =header.message;
    //}
    // if(errMsg==nil){
    //   errMsg = NSLocalizedString(@"Backend error", @"There is an error in the backed system - please try again.");        
    //} 
	//[self remoteController:self overviewResponse:nil errorMessage:errMsg];
}
 

-(void) getForretningList{
//    DLog(@"callOverview");    
NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];


[urlStr appendString:@"http://www.sandviks.dk/getForretning.php"];

NSURL *url = [NSURL URLWithString:urlStr];
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
[request setHTTPMethod:@"GET"];
[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
[request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
[request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
[request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];

GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];

fetchCount++;
[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(getForretningList:finishedWithData:error:)];
}

-(void)getForretningList:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    fetchCount--;
    if(fetchCount==0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
    //NSLog(@"SpendingData %@", jsonString);
    
    NSDictionary *json = [jsonString JSONValue];   
	//NSLog(@"json %@", json);
    
    for (NSDictionary *status in json)
    {
        NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];
        //NSLog(@"%@", [status valueForKey:@"person"]);
        payment.objectName=[status valueForKey:@"forretning"];
        [[[AppDataCache sharedAppDataSource] forretningList]addObject:payment];
    }  
}


-(void) getCurrentUser:(NSString*)ident{
    //    DLog(@"callOverview"); 
   // [[[AppDataCache sharedAppDataSource] peopleList]removeAllObjects];
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getPeople.php?email='%@'",ident];
    [urlStr appendString:mytmp];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    fetchCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(getUser:finishedWithData:error:)];
}

-(void)getUser:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    fetchCount--;
    if(fetchCount==0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
    NSLog(@"SpendingData %@", jsonString);
    
    NSDictionary *json = [jsonString JSONValue];   
	//NSLog(@"json %@", json);
    
    for (NSDictionary *status in json)
    {
        NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];
        NSLog(@"%@", [status valueForKey:@"person"]);
        //NSLog(@"%@", [status valueForKey:@"id"]);
        payment.objectName=[status valueForKey:@"person"];
         payment.ident=[[status valueForKey:@"id"]integerValue];
        [AppDataCache sharedAppDataSource].currentUserId=[[status valueForKey:@"id"]integerValue];
        [AppDataCache sharedAppDataSource].currentUsername=[status valueForKey:@"person"];
    }  
}

#pragma mark -
#pragma mark responseFromFetcher
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  responseFromFetcher
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
-(void) responseFromFetcher:(GTMHTTPFetcher *)fetcher data:(NSData *)data{
    
    //po [[d allHeaderFields] objectForKey:@"Set-Cookie"]
   // NSString *contentType = [fetcher.responseHeaders valueForKey:@"Content-Type"];
	NSURLResponse *resp =fetcher.response;
    NSHTTPURLResponse *d =(NSHTTPURLResponse*)resp;
    NSInteger statuscode=[d statusCode];
	
   // BOOL validJson = NO;
    //BOOL validStatus = NO;
    
    statuscode =[d statusCode];
    DLog(@"statuscode %d", statuscode);
    
    //NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
    //NSDictionary *json;
    //NSLog(@"%@",jsonString);
}



#pragma mark -
#pragma mark isValidJsonResponseFromFetcher
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  isValidJsonResponseFromFetcher
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
-(BOOL) isValidJsonResponseFromFetcher:(GTMHTTPFetcher *)fetcher data:(NSData *)data caller:(NSString*)caller{
    
    NSInteger statuscode=0;
    NSString *contentType = [fetcher.responseHeaders valueForKey:@"Content-Type"];
	//NSDictionary *keys = fetcher.responseHeaders;
    NSURLResponse *resp =fetcher.response;
    NSHTTPURLResponse *d =(NSHTTPURLResponse*)resp;
    
    /*
     DLog(@"fetcher.responseHeaderse: %@",fetcher.responseHeaders);
     DLog(@"contentType: %@",contentType);
     DLog(@"fetcher-type: %@",fetcher);
     DLog(@"statuskode: %d",[d statusCode]);
     DLog(@"location: %@",[fetcher.responseHeaders objectForKey:@"Location"] );   
	 */
    BOOL validJson = NO;
    BOOL validStatus = NO;
    
    if ([caller isEqualToString:kAppDataCacheLogonRestStatusCode]) {
        statuscode =201;
        //Saving the location link for logout
        //[RemoteServiceStatus sharedStatus].urlLocationLogOut = [fetcher.responseHeaders objectForKey:@"Location"];//We add which urllocation the logout has
        validJson = [contentType rangeOfString:@"application/json;"].location!=NSNotFound ;
        validStatus = [d statusCode]==statuscode;
    }
    if ([caller isEqualToString:kAppDataCacheSpendingOverviewStatusCode]) {
        statuscode =200;
        validJson = [contentType rangeOfString:@"application/json;"].location!=NSNotFound ;
        validStatus = [d statusCode]==statuscode;
    }
    if ([caller isEqualToString:kAppDataCacheMoveSpendingStatusCode]) {
        statuscode =200;
        validJson = [contentType rangeOfString:@"application/json;"].location!=NSNotFound ;
        validStatus = [d statusCode]==statuscode;
    }
    if ([caller isEqualToString:kAppDataCacheLogoutStatusCode]) {
        statuscode =200;
        validJson =YES;
        validStatus = [d statusCode]==statuscode;
    }
    if ([caller isEqualToString:kAppDataCacheListStoredTransfersStatusCode]) {
        statuscode =200;
        validJson =[contentType rangeOfString:@"application/json;"].location!=NSNotFound ;
        validStatus = [d statusCode]==statuscode;
    } 
    if ([caller isEqualToString:kAppDataCacheReadStoredPaymentStatusCode]) {
        statuscode =200;
        validJson =[contentType rangeOfString:@"application/json;"].location!=NSNotFound ;
        validStatus = [d statusCode]==statuscode;
    } 
    
    
    return validStatus && validJson;
}


-(void) remoteController:(RemoteController *)controller overviewResponse:(ProductOverviewResponse *)response  errorMessage:(NSString *)errorMessage {
	if([delegate respondsToSelector:@selector(remoteController:overviewResponse:errorMessage:)]) 
		[delegate remoteController:self overviewResponse:response errorMessage:errorMessage ];
}


@end
