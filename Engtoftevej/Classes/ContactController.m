#import "ContactController.h"
#import "NYKKeyboardAvoidingScrollView.h"
#import "JSON.h"
#import "AppDataCache.h"
#import "NSString+AESCrypt.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "NYKAlertView.h"
#import "NIDBase64.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];

@implementation ContactController
@synthesize scrollView;
@synthesize price;
@synthesize type;
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
    self.navigationItem.title =@"Send Postering";
    //Aranging keyboard for amount input
	price.text = @"";
    price.tag=3;
    price.keyboardType = UIKeyboardTypeNumberPad;//Adding keyboard with decimal
    
    
    peoplePicker =[[UIPickerView alloc]initWithFrame:CGRectZero];
    peoplePicker.tag=1;
    peoplePicker.delegate = self;
	peoplePicker.dataSource = self;
	peoplePicker.showsSelectionIndicator = YES;
    //person.inputView=peoplePicker;
    
    businessPicker =[[UIPickerView alloc]initWithFrame:CGRectZero];
    businessPicker.tag=2;
    businessPicker.delegate = self;
	businessPicker.dataSource = self;
	businessPicker.showsSelectionIndicator = YES;
    type.inputView=businessPicker;
    
    messageLbl.hidden=YES;  
    
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    startLocation = nil;
    
}

- (IBAction)sendPostering:(id)sender{
    NSLog(@"%@",price.text);
    //NSLog(@"%@",person.text);
    NSLog(@"%@",type.text);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *usernameTmp = [userDefaults objectForKey:@"username"]; 
    NSLog(@"%@",usernameTmp);
    
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
    if ([type.text length] == 0){
        alertTitle = @"Forretning mangler";
		alertMessage = @"Vælg venligst forretning.";
		shouldDisplayAlert = YES;
		nextResponder = type;
    }else if ([price.text length] == 0){
        alertTitle = @"Beløb mangler";
		alertMessage = @"Indtast venligst et beløb.";
		shouldDisplayAlert = YES;
		nextResponder = price;
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
    //NSLog(@"%@",self.photoAsString);
    //self.photoAsString =@""; //Fjwernes igen
    
    [remoteController insertPostValue:usernameTmp type:type.text pris:price.text kvittering:self.photo];
    
    price.text=@"";
    //person.text=@"";
    type.text=@"";
    messageLbl.hidden=NO; 
    //self.photoAsString =@"";
    
    [price resignFirstResponder];
    [type resignFirstResponder];
    //[person resignFirstResponder];
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
	NSLog(@"Entering didFinishPickingMediaWithInfoo");
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
    //NSLog(@"foto %@",photoAsString);
    //NSLog(@"imageData %@",topImageData);
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
    NSLog(@"latitude %@",myLatitude);
    
    NSString *myLongitude = [[NSString alloc] initWithFormat:@"%g",
                             newLocation.coordinate.longitude];
    //longitudeLbl.text = myLongitude;
    currentLongitude =[myLongitude copy];
    NSLog(@"currentLongitude %@",myLongitude);
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
     NSLog(@"sadsadsad");
    [price resignFirstResponder];
    [type resignFirstResponder];
    //[person resignFirstResponder];
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
    [self setPrice:nil];
    [self setType:nil];
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
    [type release];
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
    if (textField == type) {
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
        type.text =ggr.objectName;
    }	
	
}



@end
