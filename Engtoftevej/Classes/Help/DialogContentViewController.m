//
//  DialogContentViewController.m
//  UIXOverlayController
//
//  Created by Guy Umbright on 5/29/11.
//  Copyright 2011 Kickstand Software. All rights reserved.
//

#import "DialogContentViewController.h"
#import "NYKItemHelpInfo.h"

#define foo4random() (1.0 * (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX)

@interface DialogContentViewController ()
@property (nonatomic, retain)	NSArray			*colorSchemes;
@property (nonatomic, retain)	id				currentPopTipViewTarget;
@property (nonatomic, retain)	NSDictionary	*messages;
@property (nonatomic, retain)	NSMutableArray	*visiblePopTipViews;
@end


@implementation DialogContentViewController
@synthesize muteArray;
@synthesize colorSchemes;
@synthesize currentPopTipViewTarget;
@synthesize messages;
@synthesize visiblePopTipViews;
@synthesize closePostion;

- (id)init{
    self = [super initWithNibName:@"DialogContent" bundle:nil];
    if (self){
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [colorSchemes release];
	[currentPopTipViewTarget release];
	[messages release];
	[visiblePopTipViews release];
    [ muteArray release];    
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Her initialiseres det at man kan dobbelt tappe på skærmen
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDblTap:)];
    singleFingerTap.numberOfTapsRequired=2;
    singleFingerTap.numberOfTouchesRequired=1;
    
    [self.view addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
	
	self.visiblePopTipViews = [NSMutableArray array];
	
//	self.messages = [NSDictionary dictionaryWithObjectsAndKeys:
//					 // Rounded rect buttons
//					 @"A CMPopTipView will automatically position itself within the container view.", [NSNumber numberWithInt:11],
//					 @"A CMPopTipView will automatically orient itself above or below the target view based on the available space.", [NSNumber numberWithInt:12],
//					 @"A CMPopTipView always tries to point at the center of the target view.", [NSNumber numberWithInt:13],
//					 @"A CMPopTipView can point to any UIView subclass.", [NSNumber numberWithInt:14],
//					 @"A CMPopTipView will automatically size itself to fit the text message.", [NSNumber numberWithInt:15],
//					 @"A CMPopTipView works fine in both iPhone and iPad interfaces.", [NSNumber numberWithInt:16],
//					 // Nav bar buttons
//					 @"This CMPopTipView is pointing at a leftBarButtonItem of a navigationItem.", [NSNumber numberWithInt:21],
//					 @"Two popup animations are provided: slide and pop. Tap other buttons to see them both.", [NSNumber numberWithInt:22],
//					 // Toolbar buttons
//					 @"CMPopTipView will automatically point at buttons either above or below the containing view.", [NSNumber numberWithInt:31],
//					 @"The arrow is automatically positioned to point to the center of the target button.", [NSNumber numberWithInt:32],
//					 @"CMPopTipView knows how to point automatically to UIBarButtonItems in both nav bars and tool bars.", [NSNumber numberWithInt:33],
//					 nil];
//	
//	// Array of (backgroundColor, textColor) pairs.
//	// NSNull for either means leave as default.
//	// A color scheme will be picked randomly per CMPopTipView.
//	self.colorSchemes = [NSArray arrayWithObjects:
//						 [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
//						 [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
//						 [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
//						 [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
//						 [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
//						 [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
//						 nil];
}

-(void)handleDblTap:(UITapGestureRecognizer *)recognizer{
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    [self.overlayController dismissOverlay:DIALOG_ANIMATED];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.messages = nil;
	self.visiblePopTipViews = nil;
 }


- (void) viewDidAppear:(BOOL)animated{
    NSLog(@"appear");
    CGPoint fr;
    for(int i=0;i<[self.muteArray count];i++){
        NYKItemHelpInfo *nykInfo =[self.muteArray objectAtIndex:i];    
        fr =nykInfo.infoItemPostion;
        NSLog(@"%@",NSStringFromCGPoint(fr));        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button1 setTag:i];
        [button1 setImage:[UIImage imageNamed:@"hjaelp-spg1-blaa"] forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(openHelp:) forControlEvents:UIControlEventTouchUpInside];
        button1.frame = CGRectMake(fr.x -30 ,fr.y,30,30);        
        [self.view addSubview:button1];
    }
    
    //Add close tap-image
    //CGRect window = self.view.bounds;
    //CGSize cgsixe= window.size;
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];    
    [button1 setImage:[UIImage imageNamed:@"dobbeltclick"] forState:UIControlStateNormal];
    
    button1.frame = CGRectMake(closePostion.x,closePostion.y,110,50);
    [button1 addTarget:self action:@selector(closeOverlayViev:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button1];

}

- (IBAction) closeOverlayViev:(id) sender{
 [self.overlayController dismissOverlay:DIALOG_ANIMATED];
}

- (IBAction) openHelp:(id) sender {
    NSInteger tagNumber = ((UIControl*)sender).tag;
    NSLog(@"tagNumber %d",tagNumber);
    NYKItemHelpInfo *nykInfo =[self.muteArray objectAtIndex:tagNumber];
    NSLog(@"infoKey %@",nykInfo.infoKey);
    
    
    [self dismissAllPopTipViews];
	
	if (sender == currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];        
        NSString *message = [userDefaults objectForKey:nykInfo.infoKey];    
            
		//NSString *message = [self.messages objectForKey:[NSNumber numberWithInt:[(UIView *)sender tag]]];
		if (nil == message) {
			message = @"Vi kan desværre ikke vise en relevant tekst her.";
		}
		//NSArray *colorScheme = [colorSchemes objectAtIndex:foo4random()*[colorSchemes count]];
		//UIColor *backgroundColor = [colorScheme objectAtIndex:0];
		//UIColor *textColor = [colorScheme objectAtIndex:1];
		
        UIColor *backgroundColor = [UIColor lightGrayColor];
		UIColor *textColor = [UIColor blackColor];        
        
		CMPopTipView *popTipView = [[[CMPopTipView alloc] initWithMessage:message] autorelease];
		popTipView.delegate = self;
		if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
			popTipView.backgroundColor = backgroundColor;
		}
		if (textColor && ![textColor isEqual:[NSNull null]]) {
			popTipView.textColor = textColor;
		}
        
        popTipView.animation = arc4random() % 2;
		
		if ([sender isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)sender;
			[popTipView presentPointingAtView:button inView:self.view animated:YES];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
		}
		
		[visiblePopTipViews addObject:popTipView];
		self.currentPopTipViewTarget = sender;
	}    
}

#pragma mark -
#pragma mark CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
	[visiblePopTipViews removeObject:popTipView];
	self.currentPopTipViewTarget = nil;
}

- (void)dismissAllPopTipViews {
	while ([visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [visiblePopTipViews objectAtIndex:0];
		[visiblePopTipViews removeObjectAtIndex:0];
		[popTipView dismissAnimated:YES];
	}
}

- (void) viewDidDisappear:(BOOL)animated{
    NSLog(@"disappear");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) yesPressed:(id) sender{
    [self.overlayController dismissOverlay:DIALOG_ANIMATED];
}

- (IBAction) noPressed:(id) sender{
    [self.overlayController dismissOverlay:DIALOG_ANIMATED];
}

@end