#import "AccountingDetailViewController.h"
#import "NYKKeyboardAvoidingScrollView.h"
#import "JSON.h"
#import "AppDataCache.h"
#import "NSString+AESCrypt.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "NYKAlertView.h"
#import "FinalAccount.h"
#import "RegularSlidingTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];


#define kDefaultPageHeight 792
#define kDefaultPageWidth  612
#define kMargin 50
#define kColumnMargin 10

@implementation AccountingDetailViewController
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
@synthesize amountIaltLbl,amountPrPersonLbl;
@synthesize pdfFilePath;

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
    self.title = @"Accounting detail";
    
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
    
}
- (void)viewDidAppear:(BOOL)animated{
    //appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *img =[UIImage imageNamed:@"Smiley-sleep-icon.png"];
    [[SharedAppDelegate moneyBtn] removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateNormal];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateHighlighted];
    
    //[self beregnNow];
    NSMutableArray *arr =finalAccount.accounts;
    NSDecimalNumber *amountIalt = [NSDecimalNumber zero];
    for(int i=0;i<[arr count];i++){
        NYKGeneralAccount *acc1 =[arr objectAtIndex:i];
        ////NSLog(@"acc1== %@",acc1);
        NSDecimalNumber *amountLo = acc1.price;
        amountIalt = [amountIalt decimalNumberByAdding:amountLo];
    }
    
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:0];
    [nf setMaximumFractionDigits:2];
    
    ////NSLog(@"amountIalt== %@",amountIalt);
    [amountIaltLbl setText: [NSString  stringWithFormat:@"%@",[nf stringFromNumber:amountIalt]]];
    
    NSDecimalNumber *intDecimal = [[[NSDecimalNumber alloc] initWithInt:[[AppDataCache sharedAppDataSource].peopleList count]] autorelease];
    
    ////NSLog(@"intDecimal== %@",intDecimal);
    NSDecimalNumber *prperson  =[amountIalt decimalNumberByDividingBy:intDecimal];
    ////NSLog(@"prperson== %@",prperson);
    [amountPrPersonLbl setText: [NSString  stringWithFormat:@"%@",[nf stringFromNumber:prperson]]];
    
    
    [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    //[self openContact];
    
    ////NSLog(@"%@",self.tabBarItem.title);
    
    isOpenLetEmKnowView =YES;
    myView.frame = CGRectMake(0, 330 , 320, 210);
    [self.view addSubview:myView];
    
    //[self closeOpenedCell];
    [SharedAppDelegate hideTabBar];
    
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
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
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

-(IBAction) beregnogsend_BtnAction:(id) sender{
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Complete account"];
    [alert setMessage:@"Do you really want to settle this account?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert show];
    [alert release];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        [self beregnSendRegnskab];
	}
	else if (buttonIndex == 1)
	{
		// No
	}
}

-(IBAction) sealleregnskab_BtnAction:(id) sender{
    
    [self getAllRegnskabForID];
    
    
}

- (void)quitView: (id) sender {
    ////NSLog(@"Tryk knap:");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeThisViewNotification" object:nil];
    [[SharedAppDelegate tabBarController] setSelectedIndex:0];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"closeView" object:self.navigationController.view];
    
}

#pragma mark - MISC methods
- (void)beregnSendRegnskab{
    
    if ([[AppDataCache sharedAppDataSource].accounts count]>0) {//Er der overhovedetnoget at beregne og sende
        NSMutableArray *accountsArray =[AppDataCache sharedAppDataSource].accounts;
        
        [[AppDataCache sharedAppDataSource].personsPaymentList removeAllObjects];
        
        //Dette array indeholder hver persons udlæg
        
        NSArray *peopleArray = [AppDataCache sharedAppDataSource].peopleList;
        ////NSLog(@"%@",peopleArray);
        NSPredicate * pre;
        NSArray *jTotal;
        
        for(int i=0;i<[peopleArray count];i++){
            NYKGeneralAccount *personname =[peopleArray objectAtIndex:i];
            pre = [NSPredicate predicateWithFormat:@"objectName contains %@", personname.objectName];
            jTotal = [accountsArray filteredArrayUsingPredicate:pre];
            NSDecimalNumber *amountPrPerson = [NSDecimalNumber zero];
            for(int i=0;i<[jTotal count];i++){
                NYKGeneralAccount *acc =[jTotal objectAtIndex:i];
                NSDecimalNumber *amountLo = acc.price;
                amountPrPerson = [amountPrPerson decimalNumberByAdding:amountLo];
            }
            NYKGeneralAccount *personPayment= [[NYKGeneralAccount alloc] init];
            personPayment.objectName=personname.objectName;
            personPayment.price =amountPrPerson;
            [[AppDataCache sharedAppDataSource].personsPaymentList addObject:personPayment];
        }
        
        
        NSDecimalNumber *amountIalt = [NSDecimalNumber zero];
        for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
            NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
            NSDecimalNumber *amountLo = acc1.price;
            amountIalt = [amountIalt decimalNumberByAdding:amountLo];
        }
        ////NSLog(@"personsPaymentList==%@",[AppDataCache sharedAppDataSource].personsPaymentList);
        ////NSLog(@"amountIalt== %@",amountIalt);
        
        NSDecimalNumber *intDecimal = [[[NSDecimalNumber alloc] initWithInt:[[AppDataCache sharedAppDataSource].personsPaymentList count]] autorelease];
        
        ////NSLog(@"intDecimal== %@",intDecimal);
        NSDecimalNumber *prperson  =[amountIalt decimalNumberByDividingBy:intDecimal];
        ////NSLog(@"prperson== %@",prperson);
        
        for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
            NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
            acc1.tilgode = [acc1.price decimalNumberBySubtracting:prperson];
        }
        
        ////NSLog(@"personsPaymentList==%@",[AppDataCache sharedAppDataSource].personsPaymentList);
        
        [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
        /*
         Her skal alle rækker i databasen opdateres og sættes til AFSTEMTJN =JA
         OG der skal laves en tabel hvor regnskab gemmes for periode
         her lægges dette regnskab
         
         
         (NSDate*)fraDato tilDato:(NSDate*)tilDato regnskab:(NSString*)regnskab
         
         */
        NYKGeneralAccount *lastObj =[[AppDataCache sharedAppDataSource].accounts lastObject];
        NYKGeneralAccount *firstObj =[[AppDataCache sharedAppDataSource].accounts objectAtIndex:0 ];
        
        NSMutableString *res =[[NSMutableString alloc]init];
        NSDecimalNumber *number100= [NSDecimalNumber decimalNumberWithString:@"0"];
        for (NYKGeneralAccount *obj in [AppDataCache sharedAppDataSource].personsPaymentList) {
            //if value is higher than 100% it should be red
            if ([obj.tilgode compare:number100] ==NSOrderedDescending) {
                obj.Tilgode=number100;
            }
            [res appendString:[NSString stringWithFormat:@"Person:%@, Ud:%@, Skylder:%@;",obj.objectName,obj.price,obj.tilgode]];
        }
        NSString *regnskab =[[NSString stringWithString:res] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        ////NSLog(@"%@ ",regnskab);
        
        ////NSLog(@"%@ ",lastObj);
        ////NSLog(@"%@ ",firstObj);
        
        [remoteController updateRegnskab:lastObj.transactionDate tildato:firstObj.transactionDate regnskab:regnskab status:@"Completed"];
    }
    
    
}

-(void)beregnNow{
    NSMutableArray *accountsArray =[AppDataCache sharedAppDataSource].accounts;
    
    [[AppDataCache sharedAppDataSource].personsPaymentList removeAllObjects];
    
    //[[AppDataCache sharedAppDataSource].peopleList];
    //Dette array indeholder hver persons udlæg
    
    ////NSLog(@"%@",[AppDataCache sharedAppDataSource].peopleList);
    
    NSArray *peopleArray = [AppDataCache sharedAppDataSource].peopleList;
    ////NSLog(@"%@",peopleArray);
    NSPredicate * pre;
    NSArray *jTotal;
    
    for(int i=0;i<[peopleArray count];i++){
        NYKGeneralAccount *personname =[peopleArray objectAtIndex:i];
        pre = [NSPredicate predicateWithFormat:@"objectName contains %@", personname.objectName];
        jTotal = [accountsArray filteredArrayUsingPredicate:pre];
        NSDecimalNumber *amountPrPerson = [NSDecimalNumber zero];
        for(int i=0;i<[jTotal count];i++){
            NYKGeneralAccount *acc =[jTotal objectAtIndex:i];
            NSDecimalNumber *amountLo = acc.price;
            amountPrPerson = [amountPrPerson decimalNumberByAdding:amountLo];
        }
        NYKGeneralAccount *personPayment= [[NYKGeneralAccount alloc] init];
        personPayment.objectName=personname.objectName;
        personPayment.price =amountPrPerson;
        [[AppDataCache sharedAppDataSource].personsPaymentList addObject:personPayment];
    }
    
    
    NSDecimalNumber *amountIalt = [NSDecimalNumber zero];
    for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
        NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
        NSDecimalNumber *amountLo = acc1.price;
        amountIalt = [amountIalt decimalNumberByAdding:amountLo];
    }
    ////NSLog(@"personsPaymentList==%@",[AppDataCache sharedAppDataSource].personsPaymentList);
    ////NSLog(@"amountIalt== %@",amountIalt);
    
    NSDecimalNumber *intDecimal = [[[NSDecimalNumber alloc] initWithInt:[[AppDataCache sharedAppDataSource].personsPaymentList count]] autorelease];
    
    NSDecimalNumber *prperson  =[amountIalt decimalNumberByDividingBy:intDecimal];
    ////NSLog(@"prperson== %@",prperson);
    
    NSDecimalNumber *number100= [NSDecimalNumber decimalNumberWithString:@"0"];
    
    for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
        NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
        ////NSLog(@"price== %@",acc1.price);
        
        if ([[acc1.price decimalNumberBySubtracting:prperson] compare:number100]==NSOrderedDescending){
            acc1.tilgode= number100;
            [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:number100];
        }else{
            // //NSLog(@"price== %@",acc1.price);
            // //NSLog(@"prperson== %@",prperson);
            //acc1.tilgode = [prperson decimalNumberBySubtracting:acc1.price];
            ////NSLog(@"tilgode== %@",acc1.tilgode);
            [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:[prperson decimalNumberBySubtracting:acc1.price]];
        }
        
        
        //acc1.tilgode = [acc1.price decimalNumberBySubtracting:prperson];
    }
    
    //=IF(A24-D24>0;0;D24-B24)
    
    
    ////NSLog(@"personsPaymentList==%@",[AppDataCache sharedAppDataSource].personsPaymentList);
    
    [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    /*
     Her skal alle rækker i databasen opdateres og sættes til AFSTEMTJN =JA
     OG der skal laves en tabel hvor regnskab gemmes for periode
     her lægges dette regnskab
     
     
     (NSDate*)fraDato tilDato:(NSDate*)tilDato regnskab:(NSString*)regnskab
     
     */
    //    NYKGeneralAccount *lastObj =[[AppDataCache sharedAppDataSource].accounts lastObject];
    //    NYKGeneralAccount *firstObj =[[AppDataCache sharedAppDataSource].accounts objectAtIndex:0 ];
    //
    //    NSMutableString *res =[[NSMutableString alloc]init];
    //    //NSDecimalNumber *number100= [NSDecimalNumber decimalNumberWithString:@"0"];
    //    for (NYKGeneralAccount *obj in [AppDataCache sharedAppDataSource].personsPaymentList) {
    //        //if value is higher than 100% it should be red
    //        if ([obj.tilgode compare:number100] ==NSOrderedDescending) {
    //            obj.Tilgode=number100;
    //        }
    //        [res appendString:[NSString stringWithFormat:@"Person:%@Ud:%@ Skylder:%@",obj.objectName,obj.price,obj.tilgode]];
    //    }
    //    NSString *regnskab =[[NSString stringWithString:res] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //    //NSLog(@"%@ ",regnskab);
    //
    //    //NSLog(@"%@ ",lastObj);
    //    //NSLog(@"%@ ",firstObj);
    
    //[remoteController insertValue:lastObj.transactionDate tilDato:firstObj.transactionDate regnskab:regnskab];
    
    //sendButton.enabled=NO;
    
    showFinishedAccountings=NO;
    
}

-(void)getAllRegnskabForID{
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getAllRegnskabForID.php?ident='%d'",[AppDataCache sharedAppDataSource].currentRegnskabsID];
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
            // [[AppDataCache sharedAppDataSource].peopleList removeAllObjects];
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            ////NSLog(@"SpendingData %@", jsonString);
            
            NSDictionary *json = [jsonString JSONValue];
            NSMutableArray *finishedRegnskab = [NSMutableArray new];
            
            NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
            [dateFormatx setDateFormat:@"dd-MM-yyyy"];
            
            for (NSDictionary *status in json){
                FinalAccount *account= [[FinalAccount alloc] init];
                
                // [dateFormatx stringFromDate:general.transactionDate]
                //payment.transactionDate = [dateFormat dateFromString:[status valueForKey:@"cur_timestamp"]];
                account.startDato =[dateFormatx dateFromString:[status valueForKey:@"fraDato"]];
                account.slutDato =[dateFormatx dateFromString:[status valueForKey:@"tilDato"]];
                account.afstemtJN=[status valueForKey:@"status"];
                
                ////NSLog(@"%@", [status valueForKey:@"regnskab"]);
                NSString *tmp=[status valueForKey:@"regnskab"];
                //@"Person:Thomas, Ud:1946.7, Skylder:-432.65;Person:Charlotte, Ud:2812, Skylder:0";
                // Person:Thomas, Ud:1066, Skylder:0;Person:Charlotte, Ud:422, Skylder:-322;
                NSArray *chunks = [tmp componentsSeparatedByString: @";"];
                ////NSLog(@"%@",chunks);
                
                NSMutableArray *personer = [NSMutableArray new];
                for(int i=0;i<[chunks count];i++){
                    ////NSLog(@"%@",[chunks objectAtIndex:i]);
                    
                    if ([[chunks objectAtIndex:i] length]>1) {
                        
                        
                        NSArray *styk44 = [[chunks objectAtIndex:i] componentsSeparatedByString: @","];
                        //NSLog(@"%@",styk44);
                        NYKGeneralAccount *pers= [[NYKGeneralAccount alloc] init];
                        for(int j=0;j<[styk44 count];j++){
                            // //NSLog(@"%@",[styk44 objectAtIndex:j]);
                            NSArray *arrayTxt = [[styk44 objectAtIndex:j] componentsSeparatedByString: @":"];
                            // //NSLog(@"%d",[arrayTxt count]);
                            // //NSLog(@"%@",arrayTxt);
                            // //NSLog(@"%@",[arrayTxt objectAtIndex:1]);
                            
                            NSString *tt=[arrayTxt objectAtIndex:1];
                            // //NSLog(@"%@",tt);
                            NSString *stringWithoutSpaces = [tt stringByReplacingOccurrencesOfString:@"-" withString:@""];
                            if (j==0) {
                                pers.objectName =stringWithoutSpaces;
                            }
                            else if (j==1) {
                                pers.price =[NSDecimalNumber decimalNumberWithString:stringWithoutSpaces];
                            }
                            else if (j==2) {
                                pers.tilgode =[NSDecimalNumber decimalNumberWithString:stringWithoutSpaces];;
                            }
                        }
                        [personer addObject:pers];
                        [pers release];
                        
                        ////NSLog(@"%@",pers);
                    }
                }
                ////NSLog(@"%@",personer);
                account.accounts =personer;
                [finishedRegnskab addObject:account];
            }
            // //NSLog(@"%@",finishedRegnskab);
            [AppDataCache sharedAppDataSource].finishedAccountings = finishedRegnskab;
            showFinishedAccountings=YES;
            
            [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
        }
    }];
}


- (IBAction)beregnRegnskab:(id)sender{
    [self beregnNow];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [finalAccount.accounts count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 100;
//}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([finalAccount.accounts count] == 0 || [finalAccount.accounts count]  < indexPath.row)
        return nil;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        //        cell = [[[RegularSlidingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
        //                                                   reuseIdentifier:CellIdentifier] autorelease];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    //    ((RegularSlidingTableViewCell*)cell).textLabel.backgroundColor = [UIColor clearColor];
    //    ((RegularSlidingTableViewCell*)cell).detailTextLabel.backgroundColor = [UIColor clearColor];
    //    ((RegularSlidingTableViewCell*)cell).textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    //    ((RegularSlidingTableViewCell*)cell).detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    
    
    //[AppDataCache sharedAppDataSource].personsPaymentList
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:0];
    [nf setMaximumFractionDigits:2];
    
    NYKGeneralAccount *acc = [finalAccount.accounts objectAtIndex:indexPath.row];
    
    ////NSLog(@"%@",acc);
    cell.textLabel.text = acc.objectName;//[NSString  stringWithFormat:@"%@", acc.objectName];
    ////NSLog(@"%@  TEST",acc.tilgode);
    cell.detailTextLabel.text = [NSString  stringWithFormat:@"Expenses: %@ Must pay: %@",[nf stringFromNumber:acc.price], [nf stringFromNumber:acc.tilgode]];
    
    
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"konto-bg-2.png"]];
    cell.imageView.image = [UIImage imageNamed:@"person.png"];
    [cell setBackgroundView:myImageView];
    cell.userInteractionEnabled = NO;
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    //    [self closeOpenedCell];
    //    [(RegularSlidingTableViewCell*)[accountTable cellForRowAtIndexPath:indexPath] openDrawer];
    //    self.openedCellIndexPath = indexPath;
    //
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Properties

- (JBSlidingTableViewCell*)openedCell {
    JBSlidingTableViewCell* cell;
    
    if (nil == self.openedCellIndexPath) {
        cell = nil;
    } else {
        cell = (JBSlidingTableViewCell*)[accountTable cellForRowAtIndexPath:self.openedCellIndexPath];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Private Methods

- (void)closeOpenedCell {
    [self.openedCell closeDrawer];
    self.openedCellIndexPath = nil;
}

- (IBAction)pdfPressed:(id)sender {
    NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormatx setDateFormat:@"ddMMyy"];
    
    NSString *start=[dateFormatx stringFromDate:finalAccount.startDato];
    NSString *slut=[dateFormatx stringFromDate:finalAccount.slutDato];
    NSString *tttmp =[NSString stringWithFormat:@"%@-%@",start,slut];
    
    
    
    // create some sample data. In a real application, this would come from the database or an API.
    //NSString* path = [[NSBundle mainBundle] pathForResource:@"sampleData" ofType:@"plist"];
    //    NSDictionary* data = [NSDictionary dictionaryWithContentsOfFile:path];
    //    NSArray* students = [data objectForKey:@"Students"];
    
    // get a temprorary filename for this PDF
    NSString* path = NSTemporaryDirectory();
    
    self.pdfFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",tttmp]];
    
    // Create the PDF context using the default page size of 612 x 792.
    // This default is spelled out in the iOS documentation for UIGraphicsBeginPDFContextToFile
    UIGraphicsBeginPDFContextToFile(self.pdfFilePath, CGRectZero, nil);
    
    // get the context reference so we can render to it.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int currentPage = 0;
    
    // maximum height and width of the content on the page, byt taking margins into account.
    CGFloat maxWidth = kDefaultPageWidth - kMargin * 2;
    CGFloat maxHeight = kDefaultPageHeight - kMargin * 2;
    
    // we're going to cap the name of the class to using half of the horizontal page, which is why we're dividing by 2
    CGFloat classNameMaxWidth = maxWidth / 2;
    
    // the max width of the grade is also half, minus the margin
    //CGFloat gradeMaxWidth = (maxWidth / 2) - kColumnMargin;
    
    
    // only create the fonts once since it is a somewhat expensive operation
    UIFont* studentNameFont = [UIFont boldSystemFontOfSize:17];
    UIFont* classFont = [UIFont systemFontOfSize:15];
    
    CGFloat currentPageY = 0;
    
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:0];
    [nf setMaximumFractionDigits:2];
    
    // every student gets their own page
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
    currentPageY = kMargin;
    
    [dateFormatx setDateFormat:@"dd-MM-yyyy"];
    NSString *start2=[dateFormatx stringFromDate:finalAccount.startDato];
    NSString *slut2=[dateFormatx stringFromDate:finalAccount.slutDato];
    NSString *tttmp2 =[NSString stringWithFormat:@"%@ to %@",start2,slut2];
    
    
    // draw the student's name at the top of the page.
    NSString* nameTmp2 = [NSString stringWithFormat:@"ShareAccount report for period:%@ ",tttmp2];
    
    CGSize size = [nameTmp2 sizeWithFont:studentNameFont forWidth:maxWidth lineBreakMode:UILineBreakModeWordWrap];
    [nameTmp2 drawAtPoint:CGPointMake(kMargin, currentPageY) forWidth:maxWidth withFont:studentNameFont lineBreakMode:UILineBreakModeWordWrap];
    currentPageY += size.height;
    
    
    for (NYKGeneralAccount* acc in finalAccount.accounts){
        
        // draw the student's name at the top of the page.
        NSString* nameTmp = [NSString stringWithFormat:@"%@ ",acc.objectName];
        
        CGSize size = [nameTmp sizeWithFont:studentNameFont forWidth:maxWidth lineBreakMode:UILineBreakModeWordWrap];
        [nameTmp drawAtPoint:CGPointMake(kMargin, currentPageY) forWidth:maxWidth withFont:studentNameFont lineBreakMode:UILineBreakModeWordWrap];
        currentPageY += size.height;
        
        // draw a one pixel line under the student's name
        CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
        CGContextMoveToPoint(context, kMargin, currentPageY);
        CGContextAddLineToPoint(context, kDefaultPageWidth - kMargin, currentPageY);
        CGContextStrokePath(context);
        
        
        //[NSString  stringWithFormat:@"Expenses: %@ Must pay: %@",[nf stringFromNumber:acc.price], [nf stringFromNumber:acc.tilgode]];
        NSString* className = [NSString  stringWithFormat:@"Expenses: %@ Must pay: %@",[nf stringFromNumber:acc.price], [nf stringFromNumber:acc.tilgode]];
        // NSString* grade = [class objectForKey:@"Grade"];
        
        // before we render any text to the PDF, we need to measure it, so we'll know where to render the
        // next line.
        size = [className sizeWithFont:classFont constrainedToSize:CGSizeMake(classNameMaxWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        
        // if the current text would render beyond the bounds of the page,
        // start a new page and render it there instead
        if (size.height + currentPageY > maxHeight) {
            // create a new page and reset the current page's Y value
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
            currentPageY = kMargin;
        }
        
        // render the text
        [className drawInRect:CGRectMake(kMargin, currentPageY, classNameMaxWidth, maxHeight) withFont:classFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        
        // print the grade to the right of the class name
        //            [grade drawInRect:CGRectMake(kMargin + classNameMaxWidth + kColumnMargin, currentPageY, gradeMaxWidth, maxHeight) withFont:classFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        
        currentPageY += size.height;
        
        
        
        
        // increment the page number.
        currentPage++;
        
    }
    
    // end and save the PDF.
    UIGraphicsEndPDFContext();
    
    // Ask the user if they'd like to see the file or email it.
    UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Would you like to preview or email this PDF?"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Preview", @"Email", nil] autorelease];
    [actionSheet showInView:self.view];
    
    
    
    
    
}

#pragma mark - MFMailComposerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Action Sheet button %d", buttonIndex);
    
    if (buttonIndex == 0) {
        
        // present a preview of this PDF File.
        QLPreviewController* preview = [[[QLPreviewController alloc] init] autorelease];
        preview.dataSource = self;
        [self presentModalViewController:preview animated:YES];
        
    }
    else if(buttonIndex == 1)
    {
        // email the PDF File.
        MFMailComposeViewController* mailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
        mailComposer.mailComposeDelegate = self;
        
        
        NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
        [dateFormatx setDateFormat:@"ddMMyy"];
        
        NSString *start=[dateFormatx stringFromDate:finalAccount.startDato];
        NSString *slut=[dateFormatx stringFromDate:finalAccount.slutDato];
        NSString *tttmp =[NSString stringWithFormat:@"ShareAccount for period:%@-%@.pdf",start,slut];
        
        
        
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:self.pdfFilePath]
                               mimeType:@"application/pdf" fileName:tttmp];
        
        [self presentModalViewController:mailComposer animated:YES];
        
    }    
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.pdfFilePath];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    [self closeOpenedCell];
}


- (IBAction) segmentedControlDidChange:(id) sender {
    UISegmentedControl *grayRC = (UISegmentedControl *)sender;
    if(grayRC.selectedSegmentIndex == 0){//beregn
        ////NSLog(@"Beregn");
        [self beregnNow];
    }
    else if(grayRC.selectedSegmentIndex == 1){//beregn og send
        ////NSLog(@"Beregn og send");
        [self beregnSendRegnskab];
    }
    else if(grayRC.selectedSegmentIndex == 2){//se alle
        ////NSLog(@"Se alle");
    }
    
    
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
    [pdfFilePath release];
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

- (void)textViewDidChange:(UITextView *)textView{
    balanceLabel.hidden=YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textField{
    [scrollView adjustOffsetToIdealIfNeeded];
}




-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == name) {
        [adresse becomeFirstResponder];
    }
    
    else if (textField == adresse) {
        [postnr_by becomeFirstResponder];
    }
    
    else if (textField == postnr_by) {
        [tlfNummer becomeFirstResponder];
    }
    
    else if (textField == tlfNummer) {
        [email becomeFirstResponder];
    }
    else if (textField == email) {
        [message becomeFirstResponder];
    }
    
    else{
        [textField resignFirstResponder];
    }
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scrollView adjustOffsetToIdealIfNeeded];
}

@end
