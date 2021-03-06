#import "CreateAccount.h"
#import "NYKKeyboardAvoidingScrollView.h"
#import "JSON.h"
#import "AppDataCache.h"
#import "NSString+AESCrypt.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "NYKAlertView.h"
#import "NIDBase64.h"
#import "GTMRegex.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];

@implementation CreateAccount
@synthesize scrollView;
@synthesize emailAdresse,fuldtNavn;
@synthesize password;
@synthesize username;
@synthesize email;
@synthesize isNavigationBtn;
@synthesize message;
@synthesize sendButton;
@synthesize messageLbl,messagePhotoLbl;
@synthesize selectedImage,choosePhotoBtn, takePhotoBtn;
@synthesize currentLatitude,currentLongitude;
@synthesize locationManager, startLocation;
@synthesize photo;
@synthesize parent;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    if(remoteController==nil) {
		remoteController = [[RemoteController alloc] init];
		remoteController.delegate = self;
	}	
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[[self.navigationController navigationBar] setTintColor:[UIColor yellowColor] ];
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
    {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];        
    }else{
        [[self.navigationController navigationBar] setTintColor:[UIColor orangeColor] ];
        
    }
    
//    UIButton *settingsButton = [[UIButton alloc] init];
//    settingsButton.frame=CGRectMake(0,0,32,32);
//    [settingsButton setBackgroundImage:[UIImage imageNamed: @"ButtonCloseicon.png"] forState:UIControlStateNormal];
//    [settingsButton addTarget:self action:@selector(closeMe:) forControlEvents:UIControlEventTouchUpInside];  
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton]; 
//    [settingsButton release];
//
//    UIButton *opretButton = [[UIButton alloc] init];
//    opretButton.frame=CGRectMake(0,0,32,32);
//    [opretButton setBackgroundImage:[UIImage imageNamed: @"okidoki.png"] forState:UIControlStateNormal];
//    [opretButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];  
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:opretButton];
//    //self.navigationItem.leftBarButtonItem.enabled=NO;
//    [opretButton release];

   
    
    [super viewDidLoad];
       
    self.title = @"";
    self.navigationItem.title =@"Create new user";
    //Aranging keyboard for amount input
	emailAdresse.text = @"";
    emailAdresse.tag=3;
    
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    locationManager.delegate = self;
//    [locationManager startUpdatingLocation];
//    startLocation = nil;
    
}

-(IBAction)closeMe:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}


-(BOOL)isEmailValid:(NSString *)emailTmp {
	
	BOOL isValid = YES;
	
	NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	GTMRegex *regex = [GTMRegex regexWithPattern:emailRegEx];
	if(([regex matchesString:emailTmp]) == YES){
		NSLog(@"Registration Form: You have entered valid email address %@", emailTmp);
	}
	else {
		
		NSLog(@"Registration Form: You have entered INVALID email address %@", emailTmp);
		isValid = NO;
	}
	
	return isValid;
}


- (IBAction)login:(id)sender{
    //NSLog(@"%@",emailAdresse.text);
    //NSLog(@"%@",username.text);
    //NSLog(@"%@",password.text);
        
    
    // Validate inputs
	BOOL shouldDisplayAlert = NO;
	NSString *alertTitle = nil, *alertMessage = nil;
	UIResponder *nextResponder = nil;
    
    BOOL validEmail = [self isEmailValid:emailAdresse.text];
    if ([username.text length] == 0){
        alertTitle = @"Username missing";
        alertMessage = @"Please enter username.";
        shouldDisplayAlert = YES;
        nextResponder = username;
    }else if ([password.text length] == 0){
        alertTitle = @"Password missing";
		alertMessage = @"Please enter password.";
		shouldDisplayAlert = YES;
		nextResponder = password;
    }else if ([emailAdresse.text length] == 0 || !validEmail){
        alertTitle = @"Email missing";
		alertMessage = @"Please enter a valid email address.";
		shouldDisplayAlert = YES;
		nextResponder = emailAdresse;
    }
    
    //End last checks-Vi prompter brugeren med besked hvis der mangler noget    
	if (shouldDisplayAlert){
		id callback = ^(NSInteger buttonIndex) {
			if (nextResponder)
				[nextResponder becomeFirstResponder];
		};
		NYKAlertView *alert = [NYKAlertView alertViewWithMessage:[NSString stringWithFormat:@"%@\n%@", alertTitle, alertMessage]
														 buttons:NYKAlertViewButtonsOK
														callback:callback];
		[alert show];
		return;
	} 
    //Gemmer bruger på tlf
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:username.text forKey:@"username"];
    [userDefaults setObject:password.text forKey:@"password"];
    [userDefaults setObject:emailAdresse.text forKey:@"emailAdresse"];
    [userDefaults setObject:fuldtNavn.text forKey:@"fuldtNavn"];
    
    //Sender oplysninger til server og lægger i tabel
     [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText=@"Creating user...";
    [self createPerson:username.text password:password.text email:emailAdresse.text fuldtnavn:fuldtNavn.text];
    
    emailAdresse.text=@"";
    username.text=@"";
    password.text=@"";
    messageLbl.hidden=NO; 
    
    [emailAdresse resignFirstResponder];
    [password resignFirstResponder];
    [username resignFirstResponder];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void)createPerson:(NSString*)usernameTmp password:(NSString*)passwordTmp email:(NSString*)emailTmp fuldtnavn:(NSString*)fuldtnavn{
   
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    //NSLog(@" fuldtNavn == %@",fuldtNavn);
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/insertPerson.php?person='%@'&email='%@'&password='%@'&fuldtnavn='%@'",[usernameTmp stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[emailTmp stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[passwordTmp stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[usernameTmp stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[fuldtnavn stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
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
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            //NSLog(@"SpendingData %@", jsonString);
            [parent openLoginCreateView];
            [parent loadInvitationsForPerson];
            NSLog(@"%@",[userDefaults stringForKey:@"emailAdresse"]);
            parent.currentUser.text=usernameTmp;
            [remoteController getCurrentUser:[userDefaults stringForKey:@"emailAdresse"]];
        }
    }];          
}

-(IBAction) getPhoto:(id) sender {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	
	if((UIButton *) sender == choosePhotoBtn) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	} else {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
    
    //picker.allowsEditing = YES;
    //picker.showsCameraControls =NO;
	
	[self presentModalViewController:picker animated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//NSLog(@"Entering didFinishPickingMediaWithInfoo");
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *image2 =[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    selectedImage.image =image2;
    messagePhotoLbl.text =@"Billede af gemt.";
    
    
    NSString *blue = @"6F9619";
    int b =0;
    sscanf([blue UTF8String],"%x",&b);
    UIColor* btnColor = UIColorFromRGB(b);
    
    messagePhotoLbl.textColor =  btnColor;
    // (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
    UIImage *image3 = [Utilities imageWithImage:image2 scaledToSize:CGSizeMake(320, 480)];

   self.photo = UIImageJPEGRepresentation(image3, 1.0);
    
   //self.photoAsString = [NIDBase64 base64EncodedString:topImageData];
    ////NSLog(@"foto %@",photoAsString);
    ////NSLog(@"imageData %@",topImageData);
    //NSString* aStr = [[NSString alloc] initWithData:topImageData encoding:NSASCIIStringEncoding];
    
    
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    NSString *myLatitude = [[NSString alloc] initWithFormat:@"%g", 
                            newLocation.coordinate.latitude];
    //latitudeLbl.text = myLatitude;
    currentLatitude =[myLatitude copy];
    //NSLog(@"latitude %@",myLatitude);
    
    NSString *myLongitude = [[NSString alloc] initWithFormat:@"%g",
                             newLocation.coordinate.longitude];
    //longitudeLbl.text = myLongitude;
    currentLongitude =[myLongitude copy];
    //NSLog(@"currentLongitude %@",myLongitude);
    NSString *currentHorizontalAccuracy = [[NSString alloc] 
                                           initWithFormat:@"%g",
                                           newLocation.horizontalAccuracy];
    //horizontalAccuracy.text = currentHorizontalAccuracy;
    
    NSString *currentAltitude = [[NSString alloc] initWithFormat:@"%g",                                                          
                                 newLocation.altitude];
    //altitude.text = currentAltitude;
    [currentAltitude release];
    
    NSString *currentVerticalAccuracy = [[NSString alloc] 
                                         initWithFormat:@"%g",
                                         newLocation.verticalAccuracy];
    //verticalAccuracy.text = currentVerticalAccuracy;
    
    if (startLocation == nil)
        self.startLocation = newLocation;
    
    CLLocationDistance distanceBetween = [newLocation
                                          distanceFromLocation:startLocation];
    
    NSString *tripString = [[NSString alloc] 
                            initWithFormat:@"%f", 
                            distanceBetween];
    //distance.text = tripString;
    
    [myLatitude release];
    [myLongitude release];
    [currentHorizontalAccuracy release];
    [currentVerticalAccuracy release];
    [tripString release];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)viewWillDisappear:(BOOL)animated{
	
	[self.view endEditing:YES];
    	
    [super viewWillDisappear:animated];
}


- (void) viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    messagePhotoLbl.text =@"Tag evt. billede af kvittering.";
    messagePhotoLbl.textColor =[UIColor darkGrayColor];
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [username becomeFirstResponder];
    
}


//Remove keyboard
- (IBAction)handleTaping{
     //NSLog(@"sadsadsad");
    [emailAdresse resignFirstResponder];
    [password resignFirstResponder];
    [username resignFirstResponder];
//    [email resignFirstResponder];
//    [message resignFirstResponder];   
}



#pragma mark -
#pragma mark Blocks methods

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
    [self setEmailAdresse:nil];
    [self setPassword:nil];
    [self setUsername:nil];
   
    [self setEmail:nil];
    [self setMessage:nil];
    
    self.startLocation = nil;
    
    self.locationManager = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [scrollView release];
    [emailAdresse release];
    [password release];
    [username release];
    [photo release];
    [email release];
    [message release];
    
    [startLocation release];
   
    [locationManager release];

    [super dealloc];
}

- (void)textViewDidChange:(UITextView *)textView{
   
}

-(void)textViewDidBeginEditing:(UITextView *)textField{
    [scrollView adjustOffsetToIdealIfNeeded];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {	
    
    [scrollView adjustOffsetToIdealIfNeeded];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == username) {
        [emailAdresse becomeFirstResponder];
    }
    else if (textField == password) {
        [emailAdresse becomeFirstResponder];
    }
    else if (textField == emailAdresse) {
        [fuldtNavn becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }    
    return YES;
}

@end
