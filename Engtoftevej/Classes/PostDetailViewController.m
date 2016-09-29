#import "PostDetailViewController.h"
#import "NYKKeyboardAvoidingScrollView.h"
#import "JSON.h"
#import "AppDataCache.h"
#import "NSString+AESCrypt.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "NYKAlertView.h"
#import "FinalAccount.h"
#import "RegularSlidingTableViewCell.h"
#import "MBProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];

@implementation PostDetailViewController
@synthesize scrollView;
@synthesize name;
@synthesize adresse;
@synthesize postnr_by;
@synthesize tlfNummer;
@synthesize email;
@synthesize isNavigationBtn;
@synthesize message;
@synthesize balanceLabel,prefLabel;
@synthesize segmentControl;
@synthesize contactPref;
@synthesize accountTable;
@synthesize myView;
@synthesize showFinishedAccountings,isOpenLetEmKnowView;
@synthesize openedCellIndexPath = _openedCellIndexPath;
@synthesize bannerIsVisible;
@synthesize finalAccount;
@synthesize infolabel,amountPrPersonLbl;
@synthesize imageIndex;
@synthesize selectedImage;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    if(remoteController==nil) {
		remoteController = [[RemoteController alloc] init];
		remoteController.delegate = self;
	}
	
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, 0,-50);
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    [self.view addSubview:adView];
    adView.delegate=self;
    self.bannerIsVisible=NO;
    
    adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait,ADBannerContentSizeIdentifierLandscape,nil];
    
    
    
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[[self.navigationController navigationBar] setTintColor:[UIColor orangeColor] ];
    
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
    {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [[self.navigationController navigationBar] setTintColor:[UIColor orangeColor] ];
        
    }
    self.title = @"Posting detail";
    
    _openedCellIndexPath = nil;
    
    //    BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] intValue] >= 5;
    //    if (isIOS5) {
    //        myView.frame = CGRectMake(0, 600 , 320, 43);
    //
    //        // myView.frame = CGRectMake(0, 324 , 320, 43);
    //
    //    }else{
    //         myView.frame = CGRectMake(0, 395 , 320, 43);
    //    }
    
    //appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    UIButton *settingsButton = [[UIButton alloc] init];
//    settingsButton.frame=CGRectMake(0,0,32,32);
//    [settingsButton setBackgroundImage:[UIImage imageNamed: @"Sites-icon.png"] forState:UIControlStateNormal];
//    [settingsButton addTarget:self action:@selector(quitView:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
//    [settingsButton release];
//    self.navigationItem.rightBarButtonItem.enabled=YES;
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.frame=CGRectMake(0,0,32,32);
    [button2 setBackgroundImage:[UIImage imageNamed: @"green_back.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button2];
    [button2 release];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText=@"Retrieving receipt from server...";
    [self retrieveUploadedImage:imageIndex];
}
- (void)viewDidAppear:(BOOL)animated{
     [SharedAppDelegate hideTabBar];
    
    //appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *img =[UIImage imageNamed:@"Smiley-sleep-icon.png"];
    [[SharedAppDelegate moneyBtn] removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateNormal];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateHighlighted];
    
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


- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCreateViewNotification" object:nil];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [[AppDataCache sharedAppDataSource].personsPaymentList removeAllObjects];
    
    [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [super viewWillDisappear:animated];
    
    //    NSArray *arr =[[appDelegate tabBarController] viewControllers];
    //	for(int i=0;i<[arr count];i++){
    //        UIViewController *uicon =[arr objectAtIndex:i];
    //        uicon.tabBarItem.enabled = NO;
    //    }
    UIImage *img =[UIImage imageNamed:@"Smiley-sleep-icon.png"];
    [[SharedAppDelegate moneyBtn] removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateNormal];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateHighlighted];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
}
#pragma mark - IBAction methods

- (IBAction)openLetEmKnowView: (id) sender{
    [self openLetEmKnowView];
}

-(void)openLetEmKnowView{
    if (!isOpenLetEmKnowView) {
        [UIView beginAnimations:@"AnimatePresent" context:myView];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        myView.frame = CGRectMake(0, 330 , 320, 210);
        [UIView commitAnimations];
        isOpenLetEmKnowView=YES;
    }else {
        [UIView beginAnimations:@"AnimatePresent" context:myView];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        myView.frame = CGRectMake(0, 160 , 320, 210);
        [UIView commitAnimations];
        isOpenLetEmKnowView=NO;
    }
    
}

- (void)quitView: (id) sender {
    ////NSLog(@"Tryk knap:");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeThisViewNotification" object:nil];
    [[SharedAppDelegate tabBarController] setSelectedIndex:0];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"closeView" object:self.navigationController.view];
    
}

-(void)retrieveUploadedImage:(NSInteger)postid{
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    
    NSString *mytmp= [NSString stringWithFormat:@"http://www.sandviks.dk/uploads/%d.png", postid];
    
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
            
            selectedImage.frame = CGRectMake(31, 70 , 256, 256);
            selectedImage.image=[UIImage imageNamed: @"noImage.png"];
            infolabel.hidden=NO;
        }
        else {
            infolabel.hidden=YES;
            // Do your logic and the business logic ends up creating an array which is then parsed to the block
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            NSLog(@"SpendingData %@", jsonString);
            UIImage *img = [[UIImage alloc] initWithData:retrievedData];
            NSLog(@"%f",img.size.height);
            NSLog(@"%f",img.size.width);
            selectedImage.frame = CGRectMake(18, 44 , 283, 399);
            selectedImage.image=img;
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


- (IBAction)backBtn:(id)sender

{
    [SharedAppDelegate showTabBar];
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setName:nil];
    [self setAdresse:nil];
    [self setPostnr_by:nil];
    [self setTlfNummer:nil];
    [self setEmail:nil];
    [self setMessage:nil];
    [super viewDidUnload];
    
    
	
}


- (void)dealloc
{
    [scrollView release];
    [name release];
    [adresse release];
    [postnr_by release];
    [tlfNummer release];
    [email release];
    [message release];
    [segmentControl release];
    [contactPref release];
    
    [_openedCellIndexPath release];
    
    _openedCellIndexPath = nil;
    
    adView.delegate=nil;
    [adView release];
    
    [super dealloc];
}



@end
