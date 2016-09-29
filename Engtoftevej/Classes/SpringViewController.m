#import "SpringViewController.h"
#import "CreateAccount.h"
#import "SESpringBoard.h"
#import "BrowseViewController.h"
#import "CreateRegnskabController.h"
#import "Utilities.h"
#import "JSON.h"
#import "AppDataCache.h"
#import "LoginAccount.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "DialogContentViewController.h"
#import "NYKItemHelpInfo.h"

@implementation SpringViewController

@synthesize vc1, vc2,vc3;
@synthesize loginCreateView;
@synthesize loginButton;
@synthesize openCreateView,splashView;
@synthesize currentUser;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    if(remoteController==nil) {
		remoteController = [[RemoteController alloc] init];
		remoteController.delegate = self;
	}
    
    // add listener to detect close view events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRegnskabForPersonHandler:) name:@"regnskabCreatedNotification" object:nil ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCreateView:) name:@"hideCreateViewNotification" object:nil ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unHideCreateView:) name:@"unHideCreateViewNotification" object:nil ];
    
    
    //NSLog(@"%d",[AppDataCache sharedAppDataSource].currentUserId);
    [super viewDidLoad];

    
    loginCreateView.frame = CGRectMake(0, 409 , 320, 210);
    [self.view addSubview:loginCreateView];
    
    openCreateView=YES;
    
    //OPlysnigner om bruger gemmes i NSUSERDEFAULT
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults stringForKey:@"username"] == nil && [userDefaults stringForKey:@"password"] == nil && [userDefaults stringForKey:@"emailAdresse"] == nil) {
        [self openLoginCreateView];
        splashView.frame = CGRectMake(0, 0 , 320, 480);
        [self.view addSubview:splashView];    
        
    }else {
        //NSString *tmo = [NSString stringWithFormat:@"Loading your account",[[AppDataCache sharedAppDataSource] currentUsername]];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText=@"Loading your account";
        
        [self loadUser:[userDefaults stringForKey:@"emailAdresse"]];
        //[self loadInvitationsForPerson];
    }
    NSLog(@"%@",[[AppDataCache sharedAppDataSource] currentUsername]);
    currentUser.text = [[AppDataCache sharedAppDataSource] currentUsername];
}


-(void)buttonclick:(UIView*)clickedButton{
    //NSLog(@"test");
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSLog(@"TEST");
    openCreateView=NO;
    [self openLoginCreateView];
    
    if (![self.tabBarItem.title isEqualToString:@"Postings"]) {
        [SharedAppDelegate hideTabBar];
    }
}


- (void)loadRegnskabForPersonHandler: (NSNotification *) notification {
    [self loadRegnskabForPerson];
    //JEg vil gerne tilføje en ny til Sprinboard..men hvordan??
}

- (void)hideCreateView: (NSNotification *) notification {
    
    [UIView beginAnimations:@"AnimatePresent" context:loginCreateView];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    loginCreateView.frame = CGRectMake(0, 600 , 320, 210);
    [UIView commitAnimations];
}

- (void)unHideCreateView: (NSNotification *) notification {
    
    [UIView beginAnimations:@"AnimatePresent" context:loginCreateView];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    loginCreateView.frame = CGRectMake(0, 409 , 320, 210);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Blocks methods
-(void)loadUser:(NSString*)ident{
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getPeople.php?email='%@'",ident];
    [urlStr appendString:mytmp];
    
    //NSLog(@"urlStr %@", urlStr);
    
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
            //NSLog(@"SpendingData %@", jsonString);
            
            NSDictionary *json = [jsonString JSONValue];
            //NSLog(@"json %@", json);
            
            for (NSDictionary *status in json)
            {
                NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];
                //NSLog(@"%@", [status valueForKey:@"person"]);
                currentUser.text=[status valueForKey:@"person"];
                [AppDataCache sharedAppDataSource].currentUsername = [status valueForKey:@"person"];
                
                payment.objectName=[status valueForKey:@"person"];
                payment.ident=[[status valueForKey:@"id"]integerValue];
                [AppDataCache sharedAppDataSource].currentUserId=[[status valueForKey:@"id"]integerValue];
            }
          
            [self loadInvitationsForPerson];
        }
    }];
}



-(void)loadInvitationsForPerson{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getInvitesForEmai.php?email='%@'",[userDefaults stringForKey:@"emailAdresse"]];
    [urlStr appendString:mytmp];
    //NSLog(@"urlStr %@", urlStr);
    
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
            NSLog(@"SpendingData %@", jsonString);
            NSDictionary *json = [jsonString JSONValue];
            BOOL isEmpty = ([json count] == 0);
            if (!isEmpty) {
                
                //NSLog(@"json %@", json);
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                // Create an array of SEMenuItem objects
                //NSMutableArray *items = [NSMutableArray array];
                for (NSDictionary *status in json){
                    //NSLog(@"%d", [[status valueForKey:@"regnskabsId"]integerValue]);
                    //NSInteger tt =[[status valueForKey:@"regnskabsId"]integerValue];
                    NSString *regnnavn =[status valueForKey:@"regnskabsnavn"];
                    NSString *navn =[status valueForKey:@"inviteretAf"];
                    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"SharedAccount"
                                                                      message:[NSString stringWithFormat:@"Du er blevet inviteret til at deltage i regnskabet %@ af %@.", regnnavn,navn]
                                                                     delegate:self
                                                            cancelButtonTitle:@"Vil ikke deltage"
                                                            otherButtonTitles:@"Vil gerne deltage", nil];
                    message.tag =[[status valueForKey:@"regnskabsId"]integerValue];
                    [message show];
                    break;
                }
            }else{
                [self loadRegnskabForPerson];
            }
            
        }
    }];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	
	if([title isEqualToString:@"Vil ikke deltage"])
	{
		//NSLog(@"Vil ikke deltage.");
        //Slet invitation fra database
        [self loadRegnskabForPerson];
	}
	else {
		//NSLog(@"Vil deltage. %d",alertView.tag);
        //NSLog(@"%d",[AppDataCache sharedAppDataSource].currentUserId);
        [self addPersonToRegnskabAfterInvite:alertView.tag];
  	}
    //Invitation bliver altid slettet da det enten er JA eller NEJ
	[self deleteinviteToRegnskab:alertView.tag];
}

/*Invitation bliver slettet*/
-(void)deleteinviteToRegnskab:(NSInteger)regnskab{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/deleteInviteToRegnskab.php?regnskabsId='%d'&email='%@'",regnskab,[userDefaults stringForKey:@"emailAdresse"]];
    
    [urlStr appendString:mytmp];
    NSLog(@"urlStr %@", urlStr);
    
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
            
            //            NSString *msg = NSLocalizedString(@"Connection Error",
            //                                              @"The application encountered a connection error, please try again.");
            //
            //            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //            [alertView show];
            //            [alertView release];
            
        }
        else {
            // Do your logic and the business logic ends up creating an array which is then parsed to the block
            
            // NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            //NSLog(@"SpendingData %@", jsonString);
            
        }
    }];
}

/*Tilføjer person til et regnskab efter at denne er blevet inviteret til dette. INvitationen bliver slettet og i denne metode tilføjes til regnskab, så det loades sammen med personens andre regnskaber*/
-(void)addPersonToRegnskabAfterInvite:(NSInteger)regnskab{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/addPersonToRegnskabAfterInvite.php?regnskabsId='%d'&personId='%d'&email='%@'&user='%@'",regnskab,[AppDataCache sharedAppDataSource].currentUserId,[userDefaults stringForKey:@"emailAdresse"],[userDefaults stringForKey:@"username"]];
    
    [urlStr appendString:mytmp];
    //NSLog(@"urlStr %@", urlStr);
    
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
            
            // NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            //NSLog(@"SpendingData %@", jsonString);
            [self loadRegnskabForPerson];
            
        }
    }];
}

-(void)loadRegnskabForPerson{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getRegnskabForPerson.php?email='%@'",[userDefaults stringForKey:@"emailAdresse"]];
    [urlStr appendString:mytmp];
    //NSLog(@"urlStr %@", urlStr);
    
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
            //NSLog(@"SpendingData %@", jsonString);
            
            //Fjerner alle eksisterende resgnskab på Spingboard
            [[SESpringBoard sharedSESpringBoard].itemsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            NSDictionary *json = [jsonString JSONValue];
            //NSLog(@"json %@", json);
            
            // Create an array of SEMenuItem objects
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *status in json)
            {
                NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];
                //NSLog(@"%@", [status valueForKey:@"regnskab"]);
                payment.objectName=[status valueForKey:@"person"];
                //NSLog(@"ID = %@", [status valueForKey:@"id"]);
                //NSLog(@"oprettetAfPersonID = %@", [status valueForKey:@"oprettetAfPersonID"]);
                vc1 = [[BrowseViewController alloc] initWithNibName:@"BrowseView" bundle:nil];
                vc1.regnskabsid=[[status valueForKey:@"id"] integerValue];
                vc1.oprettetAfPerson=[[status valueForKey:@"oprettetAfPersonID"] integerValue];
                vc1.regnskabsnavn=[status valueForKey:@"navn"];
                
                // Create or reference more view controllers here
                // ...
                
                NSString *tmnp = [[status valueForKey:@"navn"]mutableCopy];
                //NSLog(@"ID = %@", tmnp);
                
                [items addObject:[SEMenuItem initWithTitle:tmnp imageName:@"cash-register-icon.png" viewController:vc1 removable:YES]];
                
            }
            //Tilføj nyt regnskab
            vc3 = [[CreateRegnskabController alloc] initWithNibName:@"CreateRegnskab" bundle:nil];
            [items addObject:[SEMenuItem initWithTitle:@"New account" imageName:@"Add-icon.png" viewController:vc3 removable:NO]];
            [self.view insertSubview:[[SESpringBoard sharedSESpringBoard] initWithData:@"ShareAccount" items:items image:[UIImage imageNamed:@"Sites-icon.png"]] belowSubview:loginCreateView];
            
            [splashView removeFromSuperview];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        }
    }];
}

- (IBAction)openLoginCreateView: (id) sender {
    [self openLoginCreateView];
}

-(void)openLoginCreateView{
    if (!openCreateView) {
        [UIView beginAnimations:@"AnimatePresent" context:loginCreateView];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        loginCreateView.frame = CGRectMake(0, 409 , 320, 210);
        [UIView commitAnimations];
        openCreateView=YES;
    }else {
        [UIView beginAnimations:@"AnimatePresent" context:loginCreateView];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        loginCreateView.frame = CGRectMake(0, 270 , 320, 210);
        [UIView commitAnimations];
        openCreateView=NO;
    }
    
}

- (IBAction)closeLoginCreateView:(id)sender {
    [self closeLoginCreateView];
}

-(void)closeLoginCreateView{
    [UIView beginAnimations:@"AnimatePresent" context:loginCreateView];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    
    loginCreateView.frame = CGRectMake(0, 600 , 320, 230);
    
    [UIView commitAnimations];
}

-(IBAction)createBruger:(id)sender{
    CreateAccount *nextViewController=[[CreateAccount alloc]initWithNibName:@"CreateAccount" bundle:nil];
    nextViewController.parent =self;
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:nextViewController];
    //NSLog(@"%@",navBar);
    [self presentModalViewController:navBar animated:YES];
    //[self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [nextViewController release];
}

-(IBAction)loginBruger:(id)sender{
    LoginAccount *login=[[LoginAccount alloc]initWithNibName:@"LoginAccount" bundle:nil];
    login.parent =self;
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:login];
    //NSLog(@"%@",navBar);
    [self presentModalViewController:navBar animated:YES];
    //[self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [login release];
}

- (IBAction) logoutBruger:(id) sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"username"];
    [userDefaults setObject:nil forKey:@"password"];
    [userDefaults setObject:nil forKey:@"emailAdresse"];
    
    [self openLoginCreateView];
    splashView.frame = CGRectMake(0, 0 , 320, 480);
    [self.view addSubview:splashView];
}

/*Denne metode skal være på alle de controllers hvor man ønsker hjælpo. Denne skal udfyldes som nedenstående med info om CGPoint om elementet hvor hjælpeknappen skal være
 */
- (IBAction) showHelpOverlay:(id) sender{
    uixOverlay = [[UIXOverlayController alloc] init];
    uixOverlay.dismissUponTouchMask = NO;
    
    DialogContentViewController* vc = [[DialogContentViewController alloc] init];
    

    //button1.frame = CGRectMake(20,cgsixe.height-150,110,50);
    vc.view.frame = self.view.frame;
    NSMutableArray *overVievArray = [[NSMutableArray alloc] init];
    
    NYKItemHelpInfo *nykInfo = [[NYKItemHelpInfo alloc] init];
    CGPoint fr1;
    if (openCreateView) {
        fr1 =CGPointMake(268, 420);
        NSLog(@"%f",fr1.x);
        NSLog(@"%f",fr1.y);
        nykInfo.infoItemPostion=fr1;
        vc.closePostion = CGPointMake(100, 210);
    }else{
        fr1 =CGPointMake(268, 290);
        NSLog(@"%f",fr1.x);
        NSLog(@"%f",fr1.y);
        vc.closePostion = CGPointMake(100, 210);
    }
    nykInfo.infoItemPostion=fr1;
    nykInfo.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 10];
    nykInfo.viewTag=0;
    [overVievArray addObject:nykInfo];
    [nykInfo release];
    
    NYKItemHelpInfo *nykInfo2 = [[NYKItemHelpInfo alloc] init];
    CGPoint fr2 =CGPointMake(300, 200);
       
    nykInfo2.infoItemPostion=fr2;
    nykInfo2.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 11];
    nykInfo2.viewTag=0;
    [overVievArray addObject:nykInfo2];
    [nykInfo2 release];
           
    NSLog(@"%@",overVievArray);
    vc.muteArray =overVievArray;
    [overVievArray release];
    [uixOverlay presentOverlayOnView:self.view withContent:vc animated:DIALOG_ANIMATED];
    
}
@end
