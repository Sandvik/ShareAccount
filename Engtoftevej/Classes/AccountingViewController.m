#import "AccountingViewController.h"
#import "NYKKeyboardAvoidingScrollView.h"
#import "JSON.h"
#import "AppDataCache.h"
#import "NSString+AESCrypt.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "NYKAlertView.h"
#import "FinalAccount.h"
#import "RegularSlidingTableViewCell.h"
#import "AccountingDetailViewController.h"
#import "DialogContentViewController.h"
#import "NYKItemHelpInfo.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];

@implementation AccountingViewController
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
@synthesize showAccountingsBtn;

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
    self.title = @"Accounting";
    
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
    
    UIButton *settingsButton = [[UIButton alloc] init];
    settingsButton.frame=CGRectMake(0,0,32,32);
    [settingsButton setBackgroundImage:[UIImage imageNamed: @"Sites-icon.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(quitView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    [settingsButton release];
    self.navigationItem.rightBarButtonItem.enabled=YES;
    
}
- (void)viewDidAppear:(BOOL)animated{
    //appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *img =[UIImage imageNamed:@"Smiley-sleep-icon.png"];
    [[SharedAppDelegate moneyBtn] removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateNormal];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateHighlighted];
    
    if (!showFinishedAccountings) {
        [self beregnNow];
    }
    
    
    [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    //[self openContact];
    
    // ////////NSLog(@"%@",self.tabBarItem.title);
    
    isOpenLetEmKnowView =YES;
    myView.frame = CGRectMake(0, 317 , 320, 210);
    [self.view addSubview:myView];
    
    [self closeOpenedCell];
    
    [SharedAppDelegate showTabBar];
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
    //////////NSLog(@"Banner view is beginning an ad action");
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
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[AppDataCache sharedAppDataSource].personsPaymentList removeAllObjects];
    
    [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [super viewWillDisappear:animated];
    
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
        myView.frame = CGRectMake(0, 317 , 320, 210);
        [UIView commitAnimations];
        isOpenLetEmKnowView=YES;
    }else {
        [UIView beginAnimations:@"AnimatePresent" context:myView];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        myView.frame = CGRectMake(0, 180 , 320, 210);
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
    if ( showFinishedAccountings==YES) {
        [self beregnNow];
    }else {
        [self getAllRegnskabForID];
        
    }
}

- (void)quitView: (id) sender {
    // ////////////NSLog(@"Tryk knap:");
    showFinishedAccountings =NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeThisViewNotification" object:nil];
    [[SharedAppDelegate tabBarController] setSelectedIndex:0];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"closeView" object:self.navigationController.view];
    
}

#pragma mark - MISC methods
- (void)beregnSendRegnskab{
    BOOL equal = [self erProcentLigelig];
    
    if ([[AppDataCache sharedAppDataSource].accounts count]>0) {//Er der overhovedetnoget at beregne og sende
        NSMutableArray *accountsArray =[AppDataCache sharedAppDataSource].accounts;
        
        [[AppDataCache sharedAppDataSource].personsPaymentList removeAllObjects];
        
        //Dette array indeholder hver persons udlæg
        
        NSArray *peopleArray = [AppDataCache sharedAppDataSource].peopleList;
        //////////NSLog(@"%@",peopleArray);
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
            personPayment.fordeling =personname.fordeling;
            [[AppDataCache sharedAppDataSource].personsPaymentList addObject:personPayment];
        }
        
        
        NSDecimalNumber *amountIalt = [NSDecimalNumber zero];
        for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
            NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
            NSDecimalNumber *amountLo = acc1.price;
            amountIalt = [amountIalt decimalNumberByAdding:amountLo];
        }
        
        NSMutableString *res =[[NSMutableString alloc]init];
        NYKGeneralAccount *lastObj =[[AppDataCache sharedAppDataSource].accounts lastObject];
        NYKGeneralAccount *firstObj =[[AppDataCache sharedAppDataSource].accounts objectAtIndex:0 ];
        NSString *regnskab =@"";
        if(equal){
            NSDecimalNumber *intDecimal = [[[NSDecimalNumber alloc] initWithInt:[[AppDataCache sharedAppDataSource].personsPaymentList count]] autorelease];
            
            NSDecimalNumber *prperson  =[amountIalt decimalNumberByDividingBy:intDecimal];
            
            for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
                NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
                acc1.tilgode = [acc1.price decimalNumberBySubtracting:prperson];
            }
            
          
            
            NSDecimalNumber *number100= [NSDecimalNumber decimalNumberWithString:@"0"];
            for (NYKGeneralAccount *obj in [AppDataCache sharedAppDataSource].personsPaymentList) {
                //if value is higher than 100% it should be red
                if ([obj.tilgode compare:number100] ==NSOrderedDescending) {
                    obj.Tilgode=number100;
                }
                [res appendString:[NSString stringWithFormat:@"Person:%@, Ud:%@, Skylder:%@;",obj.objectName,obj.price,obj.tilgode]];
            }
            regnskab =[[NSString stringWithString:res] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
           
            
        }
        else{
            NSDecimalNumber *numberZero= [NSDecimalNumber decimalNumberWithString:@"0"];
            NSDecimalNumber *number100= [NSDecimalNumber decimalNumberWithString:@"100"];
            
            for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
                NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
                NSDecimalNumber *numberFordeling= [[NSDecimalNumber alloc] initWithDouble:acc1.fordeling];
                NSLog(@"%f",acc1.fordeling);
                
                //Beløb fordelt pr person
                NSDecimalNumber *person  =[[numberFordeling decimalNumberByDividingBy:number100] decimalNumberByMultiplyingBy:amountIalt];
                NSLog(@"%@",person);
                
                
                //Finder ud af hvad folk har tilgode
                if ([[acc1.price decimalNumberBySubtracting:person] compare:numberZero]==NSOrderedDescending){
                    acc1.tilgode= numberZero;
                    [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:numberZero];
                }
                else{
                    [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:[person decimalNumberBySubtracting:acc1.price]];
                }
                
                [res appendString:[NSString stringWithFormat:@"Person:%@, Ud:%@, Skylder:%@;",acc1.objectName,acc1.price,acc1.tilgode]];
                NSLog(@"%@",res);
                regnskab =[[NSString stringWithString:res] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
            }         
        }
        [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self updateRegnskab:lastObj.transactionDate tildato:firstObj.transactionDate regnskab:regnskab status:@"Completed"];
    }
}


-(void)updateRegnskab:(NSDate*)fraDato tildato:(NSDate*)tildato regnskab:(NSString*)regnskab status:(NSString*)status{
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    
    NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormatx setDateFormat:@"dd-MM-yyyy"];
    NSString*fraDatoTmp= [dateFormatx stringFromDate:fraDato];
    NSString*tilDatoTmp= [dateFormatx stringFromDate:tildato];
    
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/insertRegnskab.php?fradato='%@'&tildato='%@'&regnskab='%@'&regnskabsid='%d'&status='%@'",fraDatoTmp,tilDatoTmp,[regnskab stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[AppDataCache sharedAppDataSource].currentRegnskabsID,status];
    [urlStr appendString:mytmp];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
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
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            NSLog(@"SpendingData %@", jsonString);
            
            [self getAllRegnskabForID];
                       
        }
    }];
    
    
}



float customFloor(float value){
    int halves = (int)(value * 2 + 0.5);
    float svar = halves * 0.5;
    NSLog(@"%f",svar);
    
    return svar;
    
    
}

//Der skal tjekkes hvad UISwitch står til -- Dette læses i Cache--værdi hentet ind fra server-Default er at alle er lige
-(BOOL)erProcentLigelig{
    if ([[AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige isEqualToString:@"LIGE"]) {
        return YES;
        
    }else{
        return NO;
        
    }
    
}

/*
 Først checkes det om procentfordeling er ligelig
 HVis den er ligelig bruges eksisterende algoritme
 ELLERS udregnes på basis af procentsatser
 */
-(void)beregnNow{
    NSMutableArray *accountsArray =[AppDataCache sharedAppDataSource].accounts;
    
    [[AppDataCache sharedAppDataSource].personsPaymentList removeAllObjects];
    
    NSArray *peopleArray = [AppDataCache sharedAppDataSource].peopleList;
    ////////NSLog(@"%@",peopleArray);
    NSPredicate * pre;
    NSArray *jTotal;
    
    //Finder total beløb pr person
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
        personPayment.fordeling=personname.fordeling;
        personPayment.price =amountPrPerson;
        [[AppDataCache sharedAppDataSource].personsPaymentList addObject:personPayment];
    }
    
    //Finder totalt beløb ialt i regnskab
    NSDecimalNumber *amountIalt = [NSDecimalNumber zero];
    for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
        NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
        NSDecimalNumber *amountLo = acc1.price;
        amountIalt = [amountIalt decimalNumberByAdding:amountLo];
    }
    
    NSDecimalNumber *intDecimal = [[[NSDecimalNumber alloc] initWithInt:[[AppDataCache sharedAppDataSource].personsPaymentList count]] autorelease];
    
    
    BOOL equal = [self erProcentLigelig];
    if (equal) {//Beløb fordeles ligeligt
        //Beløb fordelt pr person
        NSDecimalNumber *prperson  =[amountIalt decimalNumberByDividingBy:intDecimal];
        ////////NSLog(@"prperson== %@",prperson);
        
        NSDecimalNumber *number100= [NSDecimalNumber decimalNumberWithString:@"0"];
        
        for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
            NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
            
            //Finder ud af hvad folk har tilgode
            if ([[acc1.price decimalNumberBySubtracting:prperson] compare:number100]==NSOrderedDescending){
                acc1.tilgode= number100;
                [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:number100];
            }
            else{
                [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:[prperson decimalNumberBySubtracting:acc1.price]];
            }
            
        }
    }
    else{//Beløb fordeles udfra perocentvis fordeling
        
        NSDecimalNumber *numberZero= [NSDecimalNumber decimalNumberWithString:@"0"];
        
        NSDecimalNumber *number100= [NSDecimalNumber decimalNumberWithString:@"100"];
        
        for(int i=0;i<[[AppDataCache sharedAppDataSource].personsPaymentList count];i++){
            NYKGeneralAccount *acc1 =[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i];
            NSDecimalNumber *numberFordeling= [[NSDecimalNumber alloc] initWithDouble:acc1.fordeling];
            
            NSLog(@"%f",acc1.fordeling);
            //Beløb fordelt pr person
            NSDecimalNumber *person  =[[numberFordeling decimalNumberByDividingBy:number100] decimalNumberByMultiplyingBy:amountIalt];
            NSLog(@"%@",person);
            
            
            //Finder ud af hvad folk har tilgode
            if ([[acc1.price decimalNumberBySubtracting:person] compare:numberZero]==NSOrderedDescending){
                acc1.tilgode= numberZero;
                [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:numberZero];
            }
            else{
                [[[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:i] setTilgode:[person decimalNumberBySubtracting:acc1.price]];
            }
            
        }
        
        
        
    }
    
    
    
    
    [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [showAccountingsBtn setTitle: @"Tap to see all completed statements..." forState: UIControlStateNormal];
    showFinishedAccountings=NO;
    
}

-(void)getAllRegnskabForID{
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getAllRegnskabForID.php?ident='%d'",[AppDataCache sharedAppDataSource].currentRegnskabsID];
    [urlStr appendString:mytmp];
    ////////NSLog(@"urlStr %@", urlStr);
    
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
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            
            NSDictionary *json = [jsonString JSONValue];
            NSMutableArray *finishedRegnskab = [NSMutableArray new];
            
            NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
            [dateFormatx setDateFormat:@"dd-MM-yyyy"];
            
            for (NSDictionary *status in json){
                FinalAccount *account= [[FinalAccount alloc] init];
                
                account.startDato =[dateFormatx dateFromString:[status valueForKey:@"fraDato"]];
                account.slutDato =[dateFormatx dateFromString:[status valueForKey:@"tildato"]];
                account.afstemtJN=[status valueForKey:@"status"];
                
                ////////NSLog(@"%@", [status valueForKey:@"regnskab"]);
                NSString *tmp=[status valueForKey:@"regnskab"];
                NSArray *chunks = [tmp componentsSeparatedByString: @";"];
                
                NSMutableArray *personer = [NSMutableArray new];
                for(int i=0;i<[chunks count];i++){
                    
                    if ([[chunks objectAtIndex:i] length]>1) {
                        
                        
                        NSArray *styk44 = [[chunks objectAtIndex:i] componentsSeparatedByString: @","];
                        NYKGeneralAccount *pers= [[NYKGeneralAccount alloc] init];
                        for(int j=0;j<[styk44 count];j++){
                            NSArray *arrayTxt = [[styk44 objectAtIndex:j] componentsSeparatedByString: @":"];
                            
                            NSString *tt=[arrayTxt objectAtIndex:1];
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
                        
                        ////////NSLog(@"%@",pers);
                    }
                }
                ////////NSLog(@"%@",personer);
                account.accounts =personer;
                [finishedRegnskab addObject:account];
            }
            ////////NSLog(@"%@",finishedRegnskab);
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"slutDato"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            [AppDataCache sharedAppDataSource].finishedAccountings = [finishedRegnskab sortedArrayUsingDescriptors:sortDescriptors];
            
            showFinishedAccountings=YES;
            
            [accountTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
            [showAccountingsBtn setTitle: @"Tap to see current account." forState: UIControlStateNormal];
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
    if (showFinishedAccountings) {
        if ([[AppDataCache sharedAppDataSource].finishedAccountings count] == 0) {
            return 1;
        }
        else {
            return [[AppDataCache sharedAppDataSource].finishedAccountings count];
        }
    }else{
        if ([[AppDataCache sharedAppDataSource].personsPaymentList count] == 0) {
            return 1;
        }
        else {
            return [[AppDataCache sharedAppDataSource].personsPaymentList count];
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 100;
//}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    
    if (showFinishedAccountings) {
        if ([[AppDataCache sharedAppDataSource].finishedAccountings count] == 0 || [[AppDataCache sharedAppDataSource].finishedAccountings count] < indexPath.row){
            cell.textLabel.text = @"There are no completed statements";
            cell.detailTextLabel.text=@"";
            [cell.textLabel setFont:[UIFont italicSystemFontOfSize:12]];
            cell.imageView.image = [UIImage imageNamed:@"pen_write.png"];
            return cell;
        }
    }else {
        if ([[AppDataCache sharedAppDataSource].personsPaymentList count] == 0 || [[AppDataCache sharedAppDataSource].personsPaymentList count] < indexPath.row){
            cell.textLabel.text = @"There are no calculation for current account";
            cell.detailTextLabel.text=@"";
            [cell.textLabel setFont:[UIFont italicSystemFontOfSize:12]];
            cell.imageView.image = [UIImage imageNamed:@"pen_write.png"];
            return cell;
        }
    }
    
    //[AppDataCache sharedAppDataSource].personsPaymentList
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:0];
    [nf setMaximumFractionDigits:2];
    
    if (showFinishedAccountings) {
        FinalAccount *acc = [[AppDataCache sharedAppDataSource].finishedAccountings objectAtIndex:indexPath.row];
        ////////NSLog(@"%@",acc.startDato);
        ////////NSLog(@"%@",acc.slutDato);
        NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
        [dateFormatx setDateFormat:@"dd-MM-yyyy"];
        
        NSString *start=[dateFormatx stringFromDate:acc.startDato];
        NSString *slut=[dateFormatx stringFromDate:acc.slutDato];
        cell.textLabel.text =[NSString stringWithFormat:@"%@ - %@",start,slut];
        
        cell.detailTextLabel.text = acc.afstemtJN;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"time_clock.png"];
        
    }else {
        NYKGeneralAccount *acc = [[AppDataCache sharedAppDataSource].personsPaymentList objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString  stringWithFormat:@"%@", acc.objectName];
        ////////NSLog(@"%@  TEST",acc.tilgode);
        cell.detailTextLabel.text = [NSString  stringWithFormat:@"Expenses: %@ Must pay: %@",[nf stringFromNumber:acc.price], [nf stringFromNumber:acc.tilgode]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = [UIImage imageNamed:@"person.png"];
    }
    
    
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"konto-bg-2.png"]];
    
    [cell setBackgroundView:myImageView];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (showFinishedAccountings) {
        FinalAccount *acc = [[AppDataCache sharedAppDataSource].finishedAccountings objectAtIndex:indexPath.row];
        ////////NSLog(@"%@",acc.startDato);
        ////////NSLog(@"%@",acc.slutDato);
        
        
        AccountingDetailViewController *detailViewController = [[AccountingDetailViewController alloc] initWithNibName:@"accountViewDetail" bundle:nil];
        detailViewController.finalAccount = acc;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
            
    }
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

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    [self closeOpenedCell];
}


- (IBAction) segmentedControlDidChange:(id) sender {
    UISegmentedControl *grayRC = (UISegmentedControl *)sender;
    if(grayRC.selectedSegmentIndex == 0){//beregn
        ////////NSLog(@"Beregn");
        [self beregnNow];
    }
    else if(grayRC.selectedSegmentIndex == 1){//beregn og send
        ////////NSLog(@"Beregn og send");
        [self beregnSendRegnskab];
    }
    else if(grayRC.selectedSegmentIndex == 2){//se alle
        ////////NSLog(@"Se alle");
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

/*Denne metode skal være på alle de controllers hvor man ønsker hjælpo. Denne skal udfyldes som nedenstående med info om CGPoint om elementet hvor hjælpeknappen skal være
 */
- (IBAction) showHelpOverlay:(id) sender{
    uixOverlay = [[UIXOverlayController alloc] init];
    uixOverlay.dismissUponTouchMask = NO;
    
    DialogContentViewController* vc = [[DialogContentViewController alloc] init];
    vc.closePostion = CGPointMake(100, 150);
    
    //button1.frame = CGRectMake(20,cgsixe.height-150,110,50);
    vc.view.frame = self.view.frame;
    NSMutableArray *overVievArray = [[NSMutableArray alloc] init];
    
    NYKItemHelpInfo *nykInfo = [[NYKItemHelpInfo alloc] init];
    CGPoint fr1;
    if (isOpenLetEmKnowView) {
        fr1 =CGPointMake(268, 330);
        NSLog(@"%f",fr1.x);
        NSLog(@"%f",fr1.y);
        nykInfo.infoItemPostion=fr1;
        
    }else{
        fr1 =CGPointMake(268, 190);
        NSLog(@"%f",fr1.x);
        NSLog(@"%f",fr1.y);
        
    }
    nykInfo.infoItemPostion=fr1;
    nykInfo.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 14];
    nykInfo.viewTag=0;
    [overVievArray addObject:nykInfo];
    [nykInfo release];
    
    NYKItemHelpInfo *nykInfo2 = [[NYKItemHelpInfo alloc] init];
    CGPoint fr2 =CGPointMake(300, 100);
    
    nykInfo2.infoItemPostion=fr2;
    nykInfo2.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 15];
    nykInfo2.viewTag=0;
    [overVievArray addObject:nykInfo2];
    [nykInfo2 release];
    
    vc.muteArray =overVievArray;
    [overVievArray release];
    [uixOverlay presentOverlayOnView:self.view withContent:vc animated:DIALOG_ANIMATED];
    
}


@end
