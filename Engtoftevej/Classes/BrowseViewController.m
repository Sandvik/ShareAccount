#import "BrowseViewController.h"

#import "AppDataCache.h"
#import "CreateAccount.h"
#import "MainViewController.h"
#import "JSON.h"
#import "InsertPosteringController.h"
#import "LetsSlideViewController.h"
#import "iOSChatClientViewController.h"
#import "PostDetailViewController.h"
#import "DialogContentViewController.h"
#import "NYKItemHelpInfo.h"
#import "Utilities.h"

@implementation BrowseViewController
@synthesize editButton;
@synthesize table;
@synthesize regnskabsid,oprettetAfPerson;
@synthesize myView;
@synthesize smsButton,mailButton;
@synthesize letEmKnowView;
@synthesize isOpenLetEmKnowView;
@synthesize recipients;
@synthesize accountInfoTable;
@synthesize bannerIsVisible;
@synthesize regnskabsnavn;
@synthesize badgeview;
@synthesize badgeview2;

- (void)viewDidLoad {
    if(remoteController==nil) {
		remoteController = [[RemoteController alloc] init];
		remoteController.delegate = self;
	}
    
    //The ads
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, 0, -50);
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    [self.view addSubview:adView];
    adView.delegate=self;
    self.bannerIsVisible=NO;
    
    adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait,ADBannerContentSizeIdentifierLandscape,nil];
    
    
    [super viewDidLoad];
    
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
    {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [[self.navigationController navigationBar] setTintColor:[UIColor orangeColor] ];
        
    }
    
    editButton = [[UIButton alloc] init];
    editButton.frame=CGRectMake(0,0,32,32);
    [editButton setBackgroundImage:[UIImage imageNamed: @"deleter.png"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(EditTable:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    [editButton release];
    
    //UIView *rightview = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,30)];
    
    UIButton *addbutton2 = [[UIButton alloc] initWithFrame:CGRectMake(70,0,32,32)];
    [addbutton2 setBackgroundImage:[UIImage imageNamed: @"Sites-icon.png"] forState:UIControlStateNormal];
    [addbutton2 addTarget:self action:@selector(quitView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addbutton2];
    [addbutton2 release];
    
    //[rightview addSubview:addbutton2];
  
    //self.navigationItem.leftBarButtonItem.customView = rightview;
    
	self.title = @"Postings";
    
    [remoteController getForretningList];
    
    myView.frame = CGRectMake(0, 600 , 320, 150);
    
    // add listener to detect close view events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeThisViewNotification:) name:@"closeThisViewNotification" object:nil ];
    
    [SharedAppDelegate showTabBar];
    
    self.badgeview =[[MKNumberBadgeView alloc] init];
    self.badgeview.frame = CGRectMake(265, -5, 30, 30);//[[MKNumberBadgeView alloc] initWithFrame:CGRectMake(75, -2, 30, 30)];
    
    self.badgeview.font =[UIFont fontWithName:APPLICATION_FONT size:9];
    self.badgeview.shadow =NO;
    self.badgeview.pad =0.1;
    self.badgeview.shine =NO;
    self.badgeview.hidden =YES;
    
    [letEmKnowView addSubview:self.badgeview];
    
    
    
    self.badgeview2 =[[MKNumberBadgeView alloc] init];
    self.badgeview2.frame = CGRectMake(270, 142, 30, 30);//[[MKNumberBadgeView alloc] initWithFrame:CGRectMake(75, -2, 30, 30)];
    
    self.badgeview2.font =[UIFont fontWithName:APPLICATION_FONT size:9];
    self.badgeview2.shadow =NO;
    self.badgeview2.pad =0.1;
    self.badgeview2.shine =NO;
    self.badgeview2.hidden =YES;
    
    [letEmKnowView addSubview:self.badgeview2];
    
    
    accountInfoTable.scrollEnabled=NO;
    
   // [self loadInfoOmFordelingiRegnskab];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadRegnskab];
    [self loadInfoForCurrentRegnskab];
	// [self loadInfoOmFordelingiRegnskab];
	[self.table reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCreateViewNotification" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self getMessageCount];
    
    NSArray *arr =[[SharedAppDelegate tabBarController] viewControllers];
	for(int i=0;i<[arr count];i++){
        UIViewController *uicon =[arr objectAtIndex:i];
        uicon.tabBarItem.enabled = YES;
        if ([uicon isKindOfClass:[SpringViewController class]]) {
            ////NSLog(@"%@",uicon.tabBarItem.title);
            if (uicon.tabBarItem.tag ==9) {
                uicon.tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
                uicon.tabBarItem.title=@"Postings";
            }
        }
        else if ([uicon isKindOfClass:[MainViewController class]]) {
            ////NSLog(@"%@",uicon.tabBarItem.title);
            if (uicon.tabBarItem.tag ==8) {
                uicon.tabBarItem.image = [UIImage imageNamed:@"123-id-card.png"];
                uicon.tabBarItem.title=@"Accounting";
            }
        }
    }
    UIImage *img =[UIImage imageNamed:@"SmileyDollar.png"];
    [[SharedAppDelegate moneyBtn] addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateNormal];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateHighlighted];
    [[SharedAppDelegate moneyBtn] setEnabled:YES];
    [[SharedAppDelegate moneyBtn] setHidden:NO];
    [SharedAppDelegate showTabBar];
    
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
    {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [[self.navigationController navigationBar] setTintColor:[UIColor orangeColor] ];
        
    }
    isOpenLetEmKnowView =YES;
    letEmKnowView.frame = CGRectMake(0, 317 , 320, 210);
    [self.view addSubview:letEmKnowView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCreateViewNotification" object:nil];
    
    ////NSLog(@"%@",recipients);
    if ([recipients count] >0) {//Er multiselector lige forsvundet og er modtagere større end 0
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil)
        {
            // We must always check whether the current device is configured for sending emails
            if ([mailClass canSendMail])
            {
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                
                //[AppDataCache sharedAppDataSource].currentRegnskabsNavn;
                NSLog(@"%@",regnskabsnavn);
                if (regnskabsnavn == nil ) {
                    NSLog(@"prøv at kigge i cache");
                    regnskabsnavn =[AppDataCache sharedAppDataSource].currentRegnskabsNavn;
                }
                //NSArray *toRecipients = [NSArray arrayWithObjects:@"first@example.com",@"first@example.com",nil];
                
                [picker setToRecipients:recipients];
                
                [picker setSubject:@"Invitation to SharedAccount!"];
                
                //                 NSString *tmp = [NSString stringWithFormat:@"<html>"
                //                 "<body>Hi, You have been added to the account <b>%@</b> by <b>%@</b><br/><br/>"
                //                 "<b>SharedAccount</b> is an accounting application that you can use with those you"
                //                 " share an account with.<br />"
                //                 "You can use it on iPhone / iPod Touch / and iPad.<br />"
                //                 "<br/>"
                //                 "Find the app on the Appstore under the name <b>SharedAccount</b><br/>"
                //                 "When you sign up within the app use the same email address as the one you received this mail.</b><br/>"
                //                 "Sincerely,<br/> The SharedAccount Team"
                //                 "<br/></body></html>", regnskabsnavn,[AppDataCache sharedAppDataSource].currentUsername];
                //
                
                
                NSString *tmp = [NSString stringWithFormat:@"<html>"
                                 "<head>"
                                 "</head>"
                                 "<body><b><font color=\"#FF8000\">ShareAccount</font></b><br>"
                                 "Hi, You have been invited to the account <b><font color=\"#FF8000\">%@</font></b> "
                                 "by <b><font color=\"#FF8000\">%@</font></b><br>"
                                 "<br>"
                                 "<b><font color=\"#FF8000\">ShareAccount</font></b> is an accounting"
                                 " application that you can use with those you share an account with.<br>"
                                 "You can use it on iPhone / iPod Touch / and iPad.<br>"
                                 "<br>"
                                 "Find the app on the Appstore under the name <b><font color=\"#FF8000\">ShareAccount</font></b><br>"
                                 "When you sign up within the app use the same email address as the one you"
                                 "received this mail.<br>"
                                 "Sincerely,<br>"
                                 "<b><font color=\"#FF8000\">The ShareAccount Team</font></b>"
                                 "</body>"
                                 "</html>", regnskabsnavn,[AppDataCache sharedAppDataSource].currentUsername];
                
                
                
                
                [picker setMessageBody:tmp isHTML:YES];
                
                [self presentModalViewController:picker animated:YES];
                [picker release];
            }
            
        }
    }
}

#pragma mark SMS og MAIL methods

- (void)smsButtonClicked{
    //if ([self textIsValidValue:@"TEST"]) {
    [self sendSMS:@"TEST"];
    //    }
    //    else{
    //        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Du skal venligst vælge en konto først!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //        [alertView show];
    //        [alertView release];
    //    }
}

#pragma mark -
#pragma mark Workaround

- (void)sendSMS:(NSString *)bodyOfMessage {
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
    if([MFMessageComposeViewController canSendText])
    {
        NSMutableString *bodyText = [NSMutableString string];
		[bodyText appendString:@"Hey!\n"];
		[bodyText appendString:@"Du er blevet tilføjet SharedAccount, til regnskabet XXX af YYY.\n"];
        [bodyText appendString:@"SharedAccount</b> er en regnskabsapplikation, som du kan bruge sammen med dem du deler et regnskab med.\n"];
        [bodyText appendString:@"Du kan bruge det på iPhone/iPod Touch/ og iPad.\n\n"];
		[bodyText appendString:@"Find det på Appstore under navnet SharedAccount\n"];
        [bodyText appendString:@"Med venlig hilsen YYY.\n\n"];
        [bodyText appendString:@"Denne besked er sendt fra SharedAccount af YYY.\n"];
		controller.body=bodyText;
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
        
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	[self dismissModalViewControllerAnimated:YES];
    
    ////NSLog(@"%@",controller.recipients);
    
    if (result == MessageComposeResultCancelled)
        
        NSLog(@"Beskedafsendelse blev afbrudt");
    else if (result == MessageComposeResultSent)
        NSLog(@"Besked er blevet sendt");
    else
        NSLog(@"Beskedafsedelse fejlede");
}



// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	//UILabel *message;
    //message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
            [recipients removeAllObjects];
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
            ////NSLog(@"HEr skal der addes personer til regnskab");
            for(int i=0;i<[recipients count];i++){
                NSString *str = [recipients objectAtIndex:i];
                [self invitePeopleToCurrentRegnskab:str];
            }
            [recipients removeAllObjects];
            
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark tableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == accountInfoTable) {
        ////NSLog(@"");
        return 2;
    }else {
        //NSLog(@"%d",[[AppDataCache sharedAppDataSource].accounts count]);
        if ([[AppDataCache sharedAppDataSource].accounts count] == 0) {
            return 1;
        }else {
            return [[AppDataCache sharedAppDataSource].accounts count];
        }
        
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    // Set up the cell...
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    
    if (tableView == accountInfoTable) {
        //Set the text.
        if (indexPath.row == 0) {
            cell.textLabel.text = @"People";
            cell.detailTextLabel.text =@"Who else is associated with this account?";
            cell.imageView.image = [UIImage imageNamed:@"people.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Chat";
            cell.detailTextLabel.text =@"Chat with the others in this account";
            cell.imageView.image = [UIImage imageNamed:@"chat.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    else {
        UIImageView *myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"konto-bg-2.png"]];
        
        [cell setBackgroundView:myImageView];
        if ([[AppDataCache sharedAppDataSource].accounts count] == 0 || [[AppDataCache sharedAppDataSource].accounts count] < indexPath.row){
            cell.textLabel.text = @"There are no entries";
            cell.detailTextLabel.text=@"";
            [cell.textLabel setFont:[UIFont italicSystemFontOfSize:12]];
            cell.imageView.image = [UIImage imageNamed:@"chat.png"];
             cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
            return cell;
        }
        
        //Get the object from the array.
        NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
        [dateFormatx setDateFormat:@"dd-MM-yyyy"];
        
        NYKGeneralAccount *general = [[AppDataCache sharedAppDataSource].accounts objectAtIndex:indexPath.row];
        
        //Set the text.
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - (%@)",general.type, general.postnote];
        ////NSLog(@"%d",general.ident);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Amount: %@ kr. Date: %@", general.objectName,general.price,[dateFormatx stringFromDate:general.transactionDate]];
        
        cell.imageView.image = [self findRelevantImage:general.type];
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
    
    
}

-(UIImage*)findRelevantImage:(NSString*)type{
    if ([type isEqualToString:@"Transport"]) {
        return  [UIImage imageNamed:@"transportation.png"];
    }
    else if ([type isEqualToString:@"Grocery"]) {
        return  [UIImage imageNamed:@"grocery.png"];
    }
    else if ([type isEqualToString:@"Cafe and Restaurant"]) {
        return  [UIImage imageNamed:@"restaurant.png"];
    }
    else if ([type isEqualToString:@"Health and care"]) {
        return  [UIImage imageNamed:@"health.png"];
    }
    else if ([type isEqualToString:@"Housing"]) {
        return  [UIImage imageNamed:@"housing.png"];
    }
    else if ([type isEqualToString:@"Clothing and Apparel"]) {
        return  [UIImage imageNamed:@"cloth.png"];
    }
    else if ([type isEqualToString:@"Payment slip"]) {
        return  [UIImage imageNamed:@"payment.png"];
    }
    else if ([type isEqualToString:@"Other"]) {
        return  [UIImage imageNamed:@"question.png"];
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor=[UIColor lightGrayColor];
    
    // [SharedAppDelegate hideTabBar];
    
    if (tableView == accountInfoTable) {
        //åbner folk der er associeret med rgnskab
        
        
        if (indexPath.row == 0) {
            LetsSlideViewController *detailViewController = [[LetsSlideViewController alloc] initWithNibName:@"LetsSlideViewController" bundle:nil];
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            
            [accountInfoTable deselectRowAtIndexPath:indexPath animated:YES];
            
            
        }else if(indexPath.row == 1){
            iOSChatClientViewController *detailViewController = [[iOSChatClientViewController alloc] initWithNibName:@"iOSChatClientViewController" bundle:nil];
            detailViewController.parent=self;
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            
            [accountInfoTable deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
        
        
    }
    else {
        if ([[AppDataCache sharedAppDataSource].accounts count] > 0) {
            NYKGeneralAccount *general = [[AppDataCache sharedAppDataSource].accounts objectAtIndex:indexPath.row];
            
            PostDetailViewController *detailViewController = [[PostDetailViewController alloc] initWithNibName:@"postViewDetail" bundle:nil];
            detailViewController.imageIndex= general.ident;
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];

        }
       
        
               
    }
   
	
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
	[super setEditing:editing animated:animated];
    [self.table setEditing:editing animated:YES];
	
	//Do not let the user add if the app is in edit mode.
	if(editing)
		self.navigationItem.leftBarButtonItem.enabled = NO;
	else
		self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (IBAction) EditTable:(id)sender
{
	if(self.editing)
	{
		[super setEditing:NO animated:NO];
		[self.table setEditing:NO animated:NO];
		[self.table reloadData];
		[self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [editButton setBackgroundImage:[UIImage imageNamed: @"deleter.png"] forState:UIControlStateNormal];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
	}
	else
	{
		[super setEditing:YES animated:YES];
		[self.table setEditing:YES animated:YES];
		[self.table reloadData];
		[self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [editButton setBackgroundImage:[UIImage imageNamed: @"okidoki.png"] forState:UIControlStateNormal];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
	}
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // No editing style if not editing or the index path is nil.
    if (self.editing == NO || !indexPath) return UITableViewCellEditingStyleNone;
    // Determine the editing style based on whether the cell is a placeholder for adding content or already
    // existing content. Existing content can be deleted.
    if (self.editing && indexPath.row == ([[AppDataCache sharedAppDataSource].accounts count]))
	{
		return UITableViewCellEditingStyleInsert;
	} else
	{
		return UITableViewCellEditingStyleDelete;
	}
    return UITableViewCellEditingStyleNone;
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        
        [AppDataCache sharedAppDataSource].accounts = [NSMutableArray arrayWithArray:[AppDataCache sharedAppDataSource].accounts];
        
        NYKGeneralAccount *obj = [[AppDataCache sharedAppDataSource].accounts objectAtIndex:indexPath.row];
        NSInteger ident= obj.ident;
        [[AppDataCache sharedAppDataSource].accounts removeObjectAtIndex:indexPath.row];
        [remoteController deleteValue:ident];
		[self.table reloadData];
    }
}

-(void)closeMyView{
    [self closeContact];
    NSArray *arr =[[SharedAppDelegate tabBarController] viewControllers];
	for(int i=0;i<[arr count];i++){
        UIViewController *uicon =[arr objectAtIndex:i];
        if ([uicon isKindOfClass:[MainViewController class]]) {
            ////NSLog(@"%@",uicon.tabBarItem.title);
            if (uicon.tabBarItem.tag ==8) {
                uicon.tabBarItem.image = [UIImage imageNamed:@"tab_live.png"];
                uicon.tabBarItem.title=@"Info";
            }
        }else {
            uicon.tabBarItem.enabled = NO;
            uicon.tabBarItem.title = @"";
            uicon.tabBarItem.image = nil;
        }
        
        
    }
    UIImage *img =[UIImage imageNamed:@"Smiley-sleep-icon.png"];
    //[[appDelegate moneyBtn] removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [[SharedAppDelegate moneyBtn] setEnabled:NO];
    [[SharedAppDelegate moneyBtn] setHidden:YES];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateNormal];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeView" object:self.navigationController.view];
    
    
}

- (IBAction)DeleteButtonAction:(id)sender
{
	//[arry removeLastObject];
	[self.table reloadData];
}

- (void)closeThisViewNotification: (NSNotification *) notification{
    [self closeMyView];
}

#pragma mark MISC methods

- (void)quitView: (id) sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"unHideCreateViewNotification" object:nil];
    
    [self closeMyView];
}
-(void)loadInfoOmFordelingiRegnskab{
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getAfregningsModel4Regnskab.php?ident='%d'",regnskabsid];
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
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            NSLog(@"SpendingData %@", jsonString);
            
            NSDictionary *json = [jsonString JSONValue];
            
            for (NSDictionary *status in json){
                NSString * tmp =[status valueForKey:@"afregnIndividuel"];
                if ([tmp isEqualToString:@"NEJ"]) {
                    [AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige = @"LIGE";
                }
                else{
                    [AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige = @"ULIGE";
                }
            }
            
            
            if ( [[AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige isEqualToString:@"ULIGE"]) {
                  [Utilities checkPercentage];
            }    
            
        }
    }];

    
}

- (void) loadRegnskab{
    // Create a spinner while loading data
	UIActivityIndicatorView  *spinner = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	spinner.frame=CGRectMake(145, 160, 25, 25);
	spinner.tag  = 500;
	[self.table addSubview:spinner];
	[spinner startAnimating];
	
    //Sætter lige regnskabsID i cache således at hvis man når man har åbnet regsnakb ønsker at insdætte posteringer kan ID hentes derfra
    [AppDataCache sharedAppDataSource].currentRegnskabsID=regnskabsid;
	[remoteController callOverview:regnskabsid];
}

- (void)openContact: (id) sender {
    [self.view addSubview:myView];
    [UIView beginAnimations:@"AnimatePresent" context:myView];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    myView.frame = CGRectMake(0, 217 , 320, 150);
    [UIView commitAnimations];
}

- (IBAction)closeContact:(id)sender {
    [self closeContact];
}

-(void)closeContact{
    [UIView beginAnimations:@"AnimatePresent" context:myView];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    
    myView.frame = CGRectMake(0, 600 , 320, 150);
    
    [UIView commitAnimations];
}

- (void) saveSettings:(id) sender{
    ////NSLog(@"Tryk knap:");
    //[[appDelegate tabBarController] setSelectedIndex:1];
    
    InsertPosteringController* vc = [[InsertPosteringController alloc] initWithNibName:@"ContactForm" bundle:nil];
    vc.parent=self;
    //    [self presentModalViewController:vc animated:YES];
    //    [vc release];
    [SharedAppDelegate hideTabBar];
    [vc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:vc animated:YES];
    [vc release];
    
}
- (IBAction)openLetEmKnowView: (id) sender{
    [self openLetEmKnowView];
}

-(void)openLetEmKnowView{
    if (!isOpenLetEmKnowView) {
        [UIView beginAnimations:@"AnimatePresent" context:letEmKnowView];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        letEmKnowView.frame = CGRectMake(0, 317 , 320, 210);
        [UIView commitAnimations];
        isOpenLetEmKnowView=YES;
    }else {
        [UIView beginAnimations:@"AnimatePresent" context:letEmKnowView];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        letEmKnowView.frame = CGRectMake(0, 180 , 320, 210);
        [UIView commitAnimations];
        isOpenLetEmKnowView=NO;
    }
    
}

- (IBAction)closeLoginCreateView:(id)sender {
    [self closeLoginCreateView];
}

-(void)closeLoginCreateView{
    [UIView beginAnimations:@"AnimatePresent" context:letEmKnowView];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    
    letEmKnowView.frame = CGRectMake(0, 600 , 320, 230);
    
    [UIView commitAnimations];
}


-(IBAction)showModalPanel:(id)sender{
    
    CreateAccount *nextViewController=[[CreateAccount alloc]initWithNibName:@"CreateAccount" bundle:nil];
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:nextViewController];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [nextViewController release];
}

#pragma mark -
#pragma mark Blocks methods
-(void)invitePeopleToCurrentRegnskab:(NSString*)email{
    NSLog(@"%@",regnskabsnavn);
    if (regnskabsnavn == nil ) {
        NSLog(@"prøv at kigge i cache");
        regnskabsnavn =[AppDataCache sharedAppDataSource].currentRegnskabsNavn;
    }
    
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/invitePersonToRegnskab.php?regnskabsid='%d'&email='%@'&inviteretaf='%@'&regnskabsnavn='%@'",regnskabsid,email,[AppDataCache sharedAppDataSource].currentUsername,regnskabsnavn];
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
            [[AppDataCache sharedAppDataSource].peopleList removeAllObjects];
            //NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            ////NSLog(@"SpendingData %@", jsonString);
            
            //            NSDictionary *json = [jsonString JSONValue];
            //
            //            for (NSDictionary *status in json){
            //                NYKGeneralAccount *payment= [[NYKGeneralAccount alloc] init];
            //                ////NSLog(@"%@", [status valueForKey:@"regnskab"]);
            //                payment.objectName=[status valueForKey:@"usernavn"];
            //                ////NSLog(@"ID = %@", [status valueForKey:@"id"]);
            //                payment.ident=[[status valueForKey:@"id"]intValue];
            //
            //                [[[AppDataCache sharedAppDataSource] peopleList]addObject:payment];
            //                [payment release];
            //            }
            //
            //
            //            ////NSLog(@"%@",[AppDataCache sharedAppDataSource].peopleList);
            
        }
    }];
}


-(void)loadInfoForCurrentRegnskab{
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/getInfo4Regnskab.php?ident='%d'",regnskabsid];
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
            
             [self loadInfoOmFordelingiRegnskab];
         
        }
    }];
}

-(void)getMessageCount{
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/messages.php?regnskabsid='%d'&past='%d'",regnskabsid,
                       0];
    [urlStr appendString:mytmp];
    NSLog(@"urlStr %@", urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
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
            //NSLog(@"SpendingData %@", jsonString);
            NSDictionary *json = [jsonString JSONValue];
            //NSLog(@"%d",[json count]);
            
            if ([json count]>0) {
                self.badgeview2.hidden =NO;
                self.badgeview.hidden =NO;
                self.badgeview.value =[json count];
                self.badgeview2.value =[json count];
            }            
        }
    }];
}

#pragma mark -
#pragma mark MultiSelector delegate

- (IBAction)multiSelectorContactsButtonClicked
{
    [SharedAppDelegate hideTabBar];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCreateViewNotification" object:nil];
    //[self hideTabBar:self.tabBarController];
    SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
    controller.delegate = self;
    controller.requestData = DATA_CONTACT_EMAIL; // DATA_CONTACT_ID DATA_CONTACT_EMAIL , DATA_CONTACT_TELEPHONE
    controller.showModal = YES; //Mandatory: YES or NO
    controller.showCheckButton = YES; //Mandatory: YES or NO
    //controller.toolBar.frame = CGRectMake(0, 200 , 320, 44);
    
    // Set your contact list setting record ids (optional)
    //controller.recordIDs = [NSArray arrayWithObjects:@"1", @"2", nil];
    
    [self presentModalViewController:controller animated:YES];
    //[self.view addSubview:controller.toolBar];
    [controller release];
}

#pragma -
#pragma SMContactsSelectorDelegate Methods

- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type
{
    if (type == DATA_CONTACT_TELEPHONE)
    {
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            
            str = [str reformatTelephone];
            
            ////NSLog(@"Telephone: %@", str);
        }
    }
    else if (type == DATA_CONTACT_EMAIL)
    {
        recipients = [[NSMutableArray alloc] init];
        for (int i = 0; i < [data count]; i++)
        {
            NSString *str = [data objectAtIndex:i];
            
            ////NSLog(@"Emails: %@", str);
            [recipients addObject:str];
            ////NSLog(@"recipients: %@", recipients);
        }
        
    }
	else
    {
        for (int i = 0; i < [data count]; i++)
        {
            // NSString *str = [data objectAtIndex:i];
            
            ////NSLog(@"IDs: %@", str);
        }
    }
}


#pragma mark -
#pragma mark RemoteServiceController delegate

-(void) remoteController:(RemoteController *)controller overviewResponse:(ProductOverviewResponse *)response errorMessage:(NSString *)errorMessage {
	UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.table viewWithTag:500];
	[spinner removeFromSuperview];
	if(response!=nil) {
        [AppDataCache sharedAppDataSource].accounts = response.accounts; //save to cache
        
        [self.table reloadData];
        
        
        
	}else {
		NSString *msg = nil;
		if(errorMessage==nil) msg = NSLocalizedString(@"Unknown error", @"");
		else msg = [[errorMessage copy] autorelease];
		
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
        
	}
}

/*Denne metode skal være på alle de controllers hvor man ønsker hjælpo. Denne skal udfyldes som nedenstående med info om CGPoint om elementet hvor hjælpeknappen skal være
 */
- (IBAction) showHelpOverlay:(id) sender{
    uixOverlay = [[UIXOverlayController alloc] init];
    uixOverlay.dismissUponTouchMask = NO;
    
    DialogContentViewController* vc = [[DialogContentViewController alloc] init];
    vc.closePostion = CGPointMake(100, 210);
    
    //button1.frame = CGRectMake(20,cgsixe.height-150,110,50);
    vc.view.frame = self.view.frame;
    NSMutableArray *overVievArray = [[NSMutableArray alloc] init];
    
    NYKItemHelpInfo *nykInfo = [[NYKItemHelpInfo alloc] init];
    CGPoint fr1;
    if (isOpenLetEmKnowView) {
        fr1 =CGPointMake(268, 320);
        NSLog(@"%f",fr1.x);
        NSLog(@"%f",fr1.y);
        nykInfo.infoItemPostion=fr1;
 
    }else{
        fr1 =CGPointMake(268, 190);
        NSLog(@"%f",fr1.x);
        NSLog(@"%f",fr1.y);
      
    }
    nykInfo.infoItemPostion=fr1;
    nykInfo.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 12];
    nykInfo.viewTag=0;
    [overVievArray addObject:nykInfo];
    [nykInfo release];
    
    NYKItemHelpInfo *nykInfo2 = [[NYKItemHelpInfo alloc] init];
    CGPoint fr2 =CGPointMake(300, 100);
    
    nykInfo2.infoItemPostion=fr2;
    nykInfo2.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 13];
    nykInfo2.viewTag=0;
    [overVievArray addObject:nykInfo2];
    [nykInfo2 release];
    
     vc.muteArray =overVievArray;
    [overVievArray release];
    [uixOverlay presentOverlayOnView:self.view withContent:vc animated:DIALOG_ANIMATED];
    
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [badgeview2 release];
    [badgeview release];
	[addNavigationController release];
    adView.delegate=nil;
    [adView release];
    [super dealloc];
}


@end


