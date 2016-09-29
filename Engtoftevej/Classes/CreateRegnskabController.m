#import "CreateRegnskabController.h"
#import "NYKKeyboardAvoidingScrollView.h"
#import "JSON.h"
#import "AppDataCache.h"
#import "NSString+AESCrypt.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "NYKAlertView.h"
#import "NIDBase64.h"
#import "DialogContentViewController.h"
#import "NYKItemHelpInfo.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];

@implementation CreateRegnskabController
@synthesize scrollView;
@synthesize price;
@synthesize regnskabsNavn;
//@synthesize person;
@synthesize email;
@synthesize isNavigationBtn;
@synthesize message;
@synthesize sendButton;
@synthesize numberKeyPad;
@synthesize messageLbl,messagePhotoLbl;
@synthesize peoplePicker,businessPicker;
@synthesize selectedImage,choosePhotoBtn, takePhotoBtn;
@synthesize currentLatitude,currentLongitude;
@synthesize locationManager, startLocation;
@synthesize photo;


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
    
    [super viewDidLoad];
       
    self.title = @"";
    self.navigationItem.title =@"Create new accounting";
    //Aranging keyboard for amount input
	price.text = @"";
    price.tag=3;
    price.keyboardType = UIKeyboardTypeNumberPad;//Adding keyboard with decimal
    
    
    
//    
//    self.locationManager = [[CLLocationManager alloc] init];
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    locationManager.delegate = self;
//    [locationManager startUpdatingLocation];
//    startLocation = nil;
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"green_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];

    [sendButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
    {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];        
    }else{
        [[self.navigationController navigationBar] setTintColor:[UIColor orangeColor] ];
        
    }
    
    [regnskabsNavn becomeFirstResponder];
}

- (IBAction)createRegnskabAction:(id)sender{
    //NSLog(@"%@",price.text);
    ////NSLog(@"%@",person.text);
    //NSLog(@"%@",regnskabsNavn.text);
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSString *usernameTmp = [userDefaults objectForKey:@"username"];
    //NSLog(@"%@",usernameTmp);
    
    // Validate inputs
	BOOL shouldDisplayAlert = NO;
	NSString *alertTitle = nil, *alertMessage = nil;
	UIResponder *nextResponder = nil;
    
//    if ([person.text length] == 0){
//        alertTitle = @"Person mangler";
//        alertMessage = @"Vælg venligst person.";
//        shouldDisplayAlert = YES;
//        nextResponder = person;
//    }else 
    if ([regnskabsNavn.text length] == 0){
        alertTitle = @"Name is missing";
		alertMessage = @"Enter the name of the account.";
		shouldDisplayAlert = YES;
		nextResponder = regnskabsNavn;
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
    ////NSLog(@"%@",self.photoAsString);
    //self.photoAsString =@""; //Fjwernes igen
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeView" object:self.navigationController.view];
    [AppDataCache sharedAppDataSource].currentRegnskabsNavn = regnskabsNavn.text;
    [remoteController createRegnskab:regnskabsNavn.text];

    
    price.text=@"";
    //person.text=@"";
    regnskabsNavn.text=@"";
    messageLbl.hidden=NO; 
    //self.photoAsString =@"";
    
    [price resignFirstResponder];
    [regnskabsNavn resignFirstResponder];
    //[person resignFirstResponder];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"regnskabCreatedNotification" object:nil]; 
    [self dismissModalViewControllerAnimated:YES];
    
}



- (void)viewWillDisappear:(BOOL)animated{
	
	[self.view endEditing:YES];
    	
    [numberKeyPad removeButtonFromKeyboard];
    numberKeyPad = nil;
    messageLbl.hidden=YES; 
    
//    price.text=@"";
//    person.text=@"";
//    type.text=@"";
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}


- (void) viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    messagePhotoLbl.text =@"Tag evt. billede af kvittering.";
    messagePhotoLbl.textColor =[UIColor darkGrayColor];
    [super viewWillAppear:animated];
}





//Remove keyboard
- (IBAction)handleTaping{
     //NSLog(@"sadsadsad");
    [price resignFirstResponder];
    [regnskabsNavn resignFirstResponder];
    //[person resignFirstResponder];
//    [email resignFirstResponder];
//    [message resignFirstResponder];   
}

- (IBAction)dismissView:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
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
    [self setPrice:nil];
    [self setRegnskabsNavn:nil];
    //[self setPerson:nil];
   
    [self setEmail:nil];
    [self setMessage:nil];
    
    self.startLocation = nil;
    
    self.locationManager = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [scrollView release];
    [price release];
    [regnskabsNavn release];
    //[person release];
    [photo release];
    [email release];
    [message release];
    
     [numberKeyPad release];
    [startLocation release];
   
    [locationManager release];

    [super dealloc];
}

- (void)textViewDidChange:(UITextView *)textView{
   
}

-(void)textViewDidBeginEditing:(UITextView *)textField{
    [scrollView adjustOffsetToIdealIfNeeded];
}

//#pragma mark -
//#pragma mark Overriding methods for tectfield

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField.tag == 3){
        if (numberKeyPad) {        
            numberKeyPad.currentTextField = textField;
        }
    }
    
    return YES;
}



- (void) textFieldDidBeginEditing:(UITextField *)textField {	
    if (textField.tag == 3) {
        numberKeyPad = [NumberKeypadDecimalPoint keypadForTextField:price];//Adding xtra button            
    }else{
        [numberKeyPad removeButtonFromKeyboard];
        numberKeyPad = nil;
    }
    
    [scrollView adjustOffsetToIdealIfNeeded];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [numberKeyPad removeButtonFromKeyboard];
    numberKeyPad = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == regnskabsNavn) {
        [price becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    
    
    return YES;
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (thePickerView.tag ==1) {
        return [[[AppDataCache sharedAppDataSource] peopleList ]count];

    }else{ 
        return [[[AppDataCache sharedAppDataSource] forretningList ]count];
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NYKGeneralAccount *ggr;
    if (thePickerView.tag ==1) {
        ggr =[[[AppDataCache sharedAppDataSource] peopleList] objectAtIndex:row];
        
    }else{ 
        ggr =[[[AppDataCache sharedAppDataSource] forretningList] objectAtIndex:row];
    }	
	return ggr.objectName;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NYKGeneralAccount *ggr;
    if (thePickerView.tag ==1) {
        ggr =[[[AppDataCache sharedAppDataSource] peopleList] objectAtIndex:row];
        //person.text =ggr.objectName;
        
    }else{ 
        ggr =[[[AppDataCache sharedAppDataSource] forretningList] objectAtIndex:row];
        regnskabsNavn.text =ggr.objectName;
    }	
	
}

/*Denne metode skal være på alle de controllers hvor man ønsker hjælpo. Denne skal udfyldes som nedenstående med info om CGPoint om elementet hvor hjælpeknappen skal være
 */
- (IBAction) showHelpOverlay:(id) sender{
    
    uixOverlay = [[UIXOverlayController alloc] init];
    uixOverlay.dismissUponTouchMask = NO;
    
    DialogContentViewController* vc = [[DialogContentViewController alloc] init];
    vc.closePostion = CGPointMake(100, 170);
    
    //button1.frame = CGRectMake(20,cgsixe.height-150,110,50);
    vc.view.frame = self.view.frame;
    NSMutableArray *overVievArray = [[NSMutableArray alloc] init];
    
    NYKItemHelpInfo *nykInfo = [[NYKItemHelpInfo alloc] init];
    CGPoint fr1 =CGPointMake(100, 108);
    nykInfo.infoItemPostion=fr1;
    
    nykInfo.infoItemPostion=fr1;
    nykInfo.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 17];//Image
    nykInfo.viewTag=0;
    [overVievArray addObject:nykInfo];
    [nykInfo release];
    
    NYKItemHelpInfo *nykInfo2 = [[NYKItemHelpInfo alloc] init];
    CGPoint fr2 =CGPointMake(177, 108);
    nykInfo2.infoItemPostion=fr2;
    nykInfo2.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 19];//Close
    nykInfo2.viewTag=0;
    [overVievArray addObject:nykInfo2];
    [nykInfo2 release];
    
    vc.muteArray =overVievArray;
    [overVievArray release];
    [uixOverlay presentOverlayOnView:self.view withContent:vc animated:DIALOG_ANIMATED];
    
}





@end
