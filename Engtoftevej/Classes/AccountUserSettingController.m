//
//  ViewController.m
//  UIStepperDemo
//
//  Created by Uppal'z on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountUserSettingController.h"
#import "AppDataCache.h"
#import "GTMHTTPFetcher.h"
#import "GDataXMLNode.h"
#import "JSON.h"

@implementation AccountUserSettingController
@synthesize ourStepper;
@synthesize stepperValueLabel,infoLabel;
@synthesize bannerIsVisible;
@synthesize user;

#pragma mark - Action Methods

- (IBAction)stepperValueChanged:(id)sender 
{
    double stepperValue = ourStepper.value;
    self.stepperValueLabel.text = [NSString stringWithFormat:@"%.2f", stepperValue];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, 0,-50);
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    [self.view addSubview:adView];
    adView.delegate=self;
    self.bannerIsVisible=NO;
    
    adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait,ADBannerContentSizeIdentifierLandscape,nil];
    

    
    infoLabel.hidden=YES;
    
    self.ourStepper.value = user.fordeling;
    self.ourStepper.maximumValue = 100;
    self.ourStepper.stepValue = 0.5;
    self.ourStepper.wraps = YES;
    self.ourStepper.autorepeat = YES;
    self.ourStepper.continuous = YES;
    self.stepperValueLabel.text = [NSString stringWithFormat:@"%.2f", user.fordeling];
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.frame=CGRectMake(0,0,32,32);
    [button2 setBackgroundImage:[UIImage imageNamed: @"green_back.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button2];
    [button2 release];
}


//Ændrer fordelingsprocenten for pågældende bruger
- (IBAction)changeFordelingForUser: (id) sender{
    double tmp =[self.stepperValueLabel.text doubleValue];
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/changeFordelingForUser.php?personIdent='%d'&fordeling='%f'&regnskabsIdent='%d'",user.personIdent,tmp,[AppDataCache sharedAppDataSource] .currentRegnskabsID];
    [urlStr appendString:mytmp];
    NSLog(@"urlStr %@", urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            // Do your error handling logic
            
            NSString *msg = NSLocalizedString(@"Connection Error",
                                              @"The application encountered a connection error, please try again.");
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
        else {
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            NSLog(@"SpendingData %@", jsonString);            
            
            /*Hvis insert går godt fort denne person re-hentes peopleList så den er opdateret med nyeste værdier*/
            [self loadInfoForCurrentRegnskab];
            infoLabel.hidden=NO;
        }
    }];
}

-(void)loadInfoForCurrentRegnskab{
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getInfo4Regnskab.php?ident='%d'",[AppDataCache sharedAppDataSource] .currentRegnskabsID];
    [urlStr appendString:mytmp];
    ////NSLog(@"urlStr %@", urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            // Do your error handling logic
            
            NSString *msg = NSLocalizedString(@"Connection Error",
                                              @"The application encountered a connection error, please try again.");
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
        else {
            // Do your logic and the business logic ends up creating an array which is then parsed to the block
            [[AppDataCache sharedAppDataSource].peopleList removeAllObjects];
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            NSLog(@"SpendingData %@", jsonString);
            
            NSDictionary *json = [jsonString JSONValue];
            
            for (NSDictionary *status in json){
                NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];
                ////NSLog(@"%@", [status valueForKey:@"regnskab"]);
                payment.objectName=[status valueForKey:@"usernavn"];
                ////NSLog(@"ID = %@", [status valueForKey:@"id"]);
                payment.ident=[[status valueForKey:@"id"]intValue];
                payment.fordeling=[[status valueForKey:@"fordelingprocent"]doubleValue];
                payment.personIdent=[[status valueForKey:@"person"]intValue];
                payment.email=[status valueForKey:@"email"];
                [[[AppDataCache sharedAppDataSource] peopleList]addObject:payment];
                [payment release];
            }
            
            
            ////NSLog(@"%@",[AppDataCache sharedAppDataSource].peopleList);
            
        }
    }];
}


- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
        banner.frame = CGRectOffset(banner.frame, 0, 50);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    ////NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = YES;
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // resume everything you've stopped
    // [video resume];
    // [audio resume];
}


- (void)viewDidUnload
{
    [self setOurStepper:nil];
    [self setStepperValueLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backBtn:(id)sender

{
   // [SharedAppDelegate showTabBar];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [user release];
    adView.delegate=nil;
    [adView release];
    
    [super dealloc];
}

@end
