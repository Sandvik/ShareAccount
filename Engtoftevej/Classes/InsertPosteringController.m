#import "InsertPosteringController.h"
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

#define radians( degrees ) ( degrees * M_PI / 180 )

@implementation InsertPosteringController
@synthesize scrollView;
@synthesize price,postnote;
@synthesize type;
//@synthesize person;
@synthesize email;
@synthesize isNavigationBtn;
@synthesize message;
@synthesize sendButton;
@synthesize numberKeyPad;
@synthesize messageLbl,messagePhotoLbl;
@synthesize peoplePicker,businessPicker;
@synthesize choosePhotoBtn, takePhotoBtn;
@synthesize currentLatitude,currentLongitude;
@synthesize locationManager, startLocation;
@synthesize photo;
@synthesize parent;
@synthesize selectedImage;

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
    
    postnote.text=@"";
    
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
    
    //    self.locationManager = [[CLLocationManager alloc] init];
    //    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //    locationManager.delegate = self;
    //    [locationManager startUpdatingLocation];
    //    startLocation = nil;
    //
    //appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIButton *settingsButton = [[UIButton alloc] init];
    settingsButton.frame=CGRectMake(0,0,32,32);
    [settingsButton setBackgroundImage:[UIImage imageNamed: @"Sites-icon.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(quitView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    [settingsButton release];
    self.navigationItem.rightBarButtonItem.enabled=YES;
    
}

-(void)uploadImage:(NSInteger)postid{
    NSString *myImg=[NSString stringWithFormat:@"%d.png",postid];
    NSLog(@"%f",selectedImage.size.height);
    NSLog(@"%f",selectedImage.size.width);
    //UIImage *tt = selectedImage;
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.0);
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = @"http://www.sandviks.dk/uploader.php";
    [urlStr appendString:mytmp];
    NSLog(@"urlStr %@", urlStr);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n",myImg] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    // NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    
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
            
            // [self retrieveUploadedImage:1];
            
            
        }
    }];
}



- (IBAction)sendPostering:(id)sender{
    //NSLog(@"%@",price.text);
    ////NSLog(@"%@",person.text);
    NSLog(@"%@",postnote.text);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *usernameTmp = [userDefaults objectForKey:@"username"];
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
    if ([type.text length] == 0){
        alertTitle = @"Product type is missing";
		alertMessage = @"Please select product type.";
		shouldDisplayAlert = YES;
		nextResponder = type;
    }else if ([price.text length] == 0){
        alertTitle = @"Amount missing";
		alertMessage = @"Please enter an amount.";
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
    ////NSLog(@"%@",self.photoAsString);
    //self.photoAsString =@""; //Fjwernes igen
    
    [self insertPostValue:usernameTmp type:type.text pris:price.text kvittering:self.photo postnote:postnote.text];
    
    price.text=@"";
    postnote.text=@"";
    type.text=@"";
    messageLbl.hidden=NO;
    //self.photoAsString =@"";
    
    [price resignFirstResponder];
    [type resignFirstResponder];
    //[person resignFirstResponder];
}

-(void)insertPostValue:(NSString*)person type:(NSString*)typen pris:(NSString*)pris kvittering:(NSData *)kvittering postnote:(NSString *)postnoten{
    //NSString *tmpData = [NIDBase64 base64EncodedString:kvittering];
    
    
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
    
    NSDateFormatter *dateFormatx = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormatx setDateFormat:@"dd-MM-yyyy"];
    
    
    
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/indexKlunse2.php?pris=%@&person='%@'&type='%@'&regnskabsid='%d'&personid='%d'&postnote='%@'",pris,[person stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[typen stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[AppDataCache sharedAppDataSource].currentRegnskabsID,[AppDataCache sharedAppDataSource].currentUserId,[postnoten stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [urlStr appendString:mytmp];
    
    NSLog(@"%@",urlStr);
    
    //NSString *args = [NSString stringWithFormat:@"pris=%@&person='%@'&type='%@'&kvittering='%@'",pris,person,type,tmpData];
    //NSString *postLength = [NSString stringWithFormat:@"%d", [tmpData length]];
    //NSData *imageData = UIImageJPEGRepresentation(@"btn-overlay.png", 90);
    
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
            NSInteger tepm =[jsonString integerValue];
            
            NSLog(@"%f",selectedImage.size.height);
            NSLog(@"%f",selectedImage.size.width);
            messageLbl.text=@"Posting is transferred - Send more?";
            if (selectedImage.size.height > 0) {
                [self uploadImage:tepm];
            }
            
            
        }
    }];
}


-(IBAction) getPhoto:(id) sender {
    //[SharedAppDelegate hideTabBar];
    
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[picker setSourceType:UIImagePickerControllerSourceTypeCamera];
	} else {
		[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
    
    //picker.allowsEditing = YES;
    //picker.showsCameraControls =NO;
	
	[self presentModalViewController:picker animated:YES];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES]; //Do this first!!
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage* smallImage = [self imageWithImage:image scaledToSize:CGSizeMake(320.0f,480.0f)];
    
    NSLog(@"%f",smallImage.size.height);
    selectedImage =[smallImage copy];
    
    NSLog(@"%f",selectedImage.size.height);
    messageLbl.hidden=NO;
    messageLbl.text=@"Photo has been taken and is ready for upload!.";
    
}

- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeKeepingAspect:(CGSize)targetSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGContextRef bitmap;
    CGImageRef imageRef = [sourceImage CGImage];
    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown)
    {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, 8, 4 * targetWidth, genericColorSpace, kCGImageAlphaPremultipliedFirst);
        
    }
    else
    {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, 8, 4 * targetWidth, genericColorSpace, kCGImageAlphaPremultipliedFirst);
        
    }
    
    CGColorSpaceRelease(genericColorSpace);
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationDefault);
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft)
    {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    }
    else if (sourceImage.imageOrientation == UIImageOrientationRight)
    {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    }
    else if (sourceImage.imageOrientation == UIImageOrientationUp)
    {
        // NOTHING
    }
    else if (sourceImage.imageOrientation == UIImageOrientationDown)
    {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

- (void)quitView: (id) sender {
    //NSLog(@"Tryk knap:");
    [[SharedAppDelegate tabBarController] setSelectedIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeThisViewNotification" object:nil];
    
    
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
    //distance.text = tripString;ight
    
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
 
    [super viewWillDisappear:animated];
}


- (void) viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    messagePhotoLbl.text =@"Tag evt. billede af kvittering.";
    messagePhotoLbl.textColor =[UIColor darkGrayColor];
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCreateViewNotification" object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    //NSLog(@"%@",[[appDelegate tabBarController] viewControllers]);
    
    NSArray *arr =[[SharedAppDelegate tabBarController] viewControllers];
	for(int i=0;i<[arr count];i++){
        UIViewController *uicon =[arr objectAtIndex:i];
        uicon.tabBarItem.enabled = YES;
    }
    UIImage *img =[UIImage imageNamed:@"SmileyDollar.png"];
    //[[appDelegate moneyBtn] addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateNormal];
    [[SharedAppDelegate moneyBtn] setBackgroundImage:img forState:UIControlStateHighlighted];
    [[SharedAppDelegate moneyBtn] setEnabled:YES];
    [[SharedAppDelegate moneyBtn] setHidden:NO];
    
    [type becomeFirstResponder];
}


- (IBAction)dismissView:(id)sender {
    [parent loadRegnskab];
    [SharedAppDelegate showTabBar];
    [self dismissModalViewControllerAnimated:YES];
}


//Remove keyboard
- (IBAction)handleTaping{
    //NSLog(@"sadsadsad");
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

/*Denne metode skal være på alle de controllers hvor man ønsker hjælpo. Denne skal udfyldes som nedenstående med info om CGPoint om elementet hvor hjælpeknappen skal være
 */
- (IBAction) showHelpOverlay:(id) sender{
 
    [price resignFirstResponder];
    [type resignFirstResponder];
    
    uixOverlay = [[UIXOverlayController alloc] init];
    uixOverlay.dismissUponTouchMask = NO;
    
    DialogContentViewController* vc = [[DialogContentViewController alloc] init];
    vc.closePostion = CGPointMake(100, 110);
    
    //button1.frame = CGRectMake(20,cgsixe.height-150,110,50);
    vc.view.frame = self.view.frame;
    NSMutableArray *overVievArray = [[NSMutableArray alloc] init];
    
    NYKItemHelpInfo *nykInfo = [[NYKItemHelpInfo alloc] init];
    CGPoint fr1 =CGPointMake(49, 201);
    nykInfo.infoItemPostion=fr1;
   
    nykInfo.infoItemPostion=fr1;
    nykInfo.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 16];//Image
    nykInfo.viewTag=0;
    [overVievArray addObject:nykInfo];
    [nykInfo release];
    
    NYKItemHelpInfo *nykInfo2 = [[NYKItemHelpInfo alloc] init];
    CGPoint fr2 =CGPointMake(134, 200);
    nykInfo2.infoItemPostion=fr2;
    nykInfo2.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 17];//Close
    nykInfo2.viewTag=0;
    [overVievArray addObject:nykInfo2];
    [nykInfo2 release];
    
    NYKItemHelpInfo *nykInfo3 = [[NYKItemHelpInfo alloc] init];
    CGPoint fr3 =CGPointMake(217, 200);
    nykInfo3.infoItemPostion=fr3;
    nykInfo3.infoKey=[NSString stringWithFormat:@"Help_deposit%d", 18];//ok
    nykInfo3.viewTag=0;
    [overVievArray addObject:nykInfo3];
    [nykInfo3 release];
    
    vc.muteArray =overVievArray;
    [overVievArray release];
    [uixOverlay presentOverlayOnView:self.view withContent:vc animated:DIALOG_ANIMATED];
    
}



@end
