//
//  ViewController.m
//  SESpringBoardDemo
//
//  Created by Sarp Erdag on 11/5/11.
//  Copyright (c) 2011 Sarp Erdag. All rights reserved.
//

#import "SpringViewController.h"
#import "CreateAccount.h"
#import "SESpringBoard.h"
#import "BrowseViewController.h"
#import "CreateRegnskabController.h"
#import "Utilities.h"
#import "JSON.h"

@implementation SpringViewController

@synthesize vc1, vc2,vc3;
@synthesize loginCreateView;


#pragma mark - View lifecycle

- (void)viewDidLoad {
    if(remoteController==nil) {
		remoteController = [[RemoteController alloc] init];
		remoteController.delegate = self;
	}
    
    
    // add listener to detect close view events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRegnskabForPersonHandler:) name:@"regnskabCreatedNotification" object:nil ];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [super viewDidLoad];    
    [self loadRegnskabForPerson];
    [remoteController getCurrentUser:[userDefaults stringForKey:@"emailAdresse"]];
    
    loginCreateView = [[[UIView alloc] initWithFrame:CGRectMake(0, 200 , 320, 23)] autorelease];
    UIView *loginSpec = [[[UIView alloc] initWithFrame:CGRectMake(0, 38, 320, 192)] autorelease];
    
    UILabel *periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 20, 285, 21)];
    periodLabel.text =@"Your SharedAccount, Everywhere";
    periodLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
    periodLabel.textColor = [UIColor blackColor];
    periodLabel.backgroundColor = [UIColor clearColor];
    [loginSpec addSubview:periodLabel];
    [periodLabel release];
    
//    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 150, 27)];
//    descLabel.text =descriptionLabel.text;
//    descLabel.font = [UIFont fontWithName:@"Verdana" size:10];
//    descLabel.textColor = [UIColor colorWithRed:102/255 green:102/255 blue:102/255 alpha:1];
//    descLabel.backgroundColor = [UIColor clearColor];
//    descLabel.minimumFontSize = 8;
//    [movingView addSubview:descLabel];
//    [descLabel release];
    
    UIImage *outtrayNormalImage = [[UIImage imageNamed:@"btn-brik-utext.png"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:17.0];
    UIButton *accOuttrayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	accOuttrayButton.frame = CGRectMake(81,127,72,37);
	accOuttrayButton.enabled = YES;
    accOuttrayButton.titleLabel.text=@"Send";
    accOuttrayButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	[accOuttrayButton addTarget:self action:@selector(openLoginCreateView:) forControlEvents:UIControlEventTouchUpInside];
	[accOuttrayButton setBackgroundImage:outtrayNormalImage forState:UIControlStateNormal];
	[accOuttrayButton setBackgroundImage:outtrayNormalImage forState:UIControlStateDisabled];
    [loginSpec addSubview:accOuttrayButton];
    [accOuttrayButton release];
    
    [loginCreateView addSubview:loginSpec];
    [self.view addSubview:loginCreateView]; 
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated]; 
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults stringForKey:@"username"] == nil && [userDefaults stringForKey:@"password"] == nil && [userDefaults stringForKey:@"emailAdresse"] == nil) {
        CreateAccount *nextViewController=[[CreateAccount alloc]initWithNibName:@"CreateAccount" bundle:nil];
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:nextViewController];
        NSLog(@"%@",navBar);
         [self presentModalViewController:navBar animated:YES];  
        //[self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [nextViewController release];
        
    }      
} 

- (void)loadRegnskabForPersonHandler: (NSNotification *) notification {
    [self loadRegnskabForPerson];
    //JEg vil gerne tilføje en ny til Sprinboard..men hvordan??
}

#pragma mark -
#pragma mark Blocks methods


-(void)loadRegnskabForPerson{
     
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getRegnskabForPerson.php?email='%@'",[userDefaults stringForKey:@"emailAdresse"]];
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
            // Do your logic and the business logic ends up creating an array which is then parsed to the block
                   
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            NSLog(@"SpendingData %@", jsonString);
            
            NSDictionary *json = [jsonString JSONValue];   
            NSLog(@"json %@", json);
            
            // Create an array of SEMenuItem objects
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *status in json)
            {
                NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];
                NSLog(@"%@", [status valueForKey:@"regnskab"]);
                payment.objectName=[status valueForKey:@"person"];
                NSLog(@"ID = %@", [status valueForKey:@"id"]);
                
                vc1 = [[BrowseViewController alloc] initWithNibName:@"BrowseView" bundle:nil];
                vc1.regnskabsid=[[status valueForKey:@"id"] integerValue];
                // Create or reference more view controllers here
                // ...
                
                NSString *tmnp = [[status valueForKey:@"navn"]mutableCopy];
                NSLog(@"ID = %@", tmnp);
               
                [items addObject:[SEMenuItem initWithTitle:tmnp imageName:@"cash-register-icon.png" viewController:vc1 removable:YES]];
                               
            }
            //Tilføj nyt regnskab
            vc3 = [[CreateRegnskabController alloc] initWithNibName:@"CreateRegnskab" bundle:nil];
            [items addObject:[SEMenuItem initWithTitle:@"Nyt regnskab" imageName:@"Add-icon.png" viewController:vc3 removable:NO]];
           // (id) initWithTitle:(NSString *)boardTitle items:(NSMutableArray *)menuItems image:(UIImage *) image
            // [[AppDataCache sharedAppDataSource].personsPaymentList removeAllObjects];
            
            //SESpringBoard * gg= [[SESpringBoard sharedSESpringBoard] initWithData:@"Regnskab" items:items image:[UIImage imageNamed:@"Sites-icon.png"]];
            [self.view addSubview:[[SESpringBoard sharedSESpringBoard] initWithData:@"Regnskab" items:items image:[UIImage imageNamed:@"Sites-icon.png"]]]; 
            //[gg release];
        }
    }];          
}

- (IBAction)openLoginCreateView: (id) sender {  
    [self openLoginCreateView];
}

-(void)openLoginCreateView{
    [UIView beginAnimations:@"AnimatePresent" context:loginCreateView];
    [UIView setAnimationDuration:0];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];    
    loginCreateView.frame = CGRectMake(0, 100 , 320, 230);    
    [UIView commitAnimations];   
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

@end
