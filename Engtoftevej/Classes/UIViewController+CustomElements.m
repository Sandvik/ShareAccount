//
//  UIViewController+CustomElements.m
//  CopenhagenCityHouses
//
//  Created by Sergey on 30.01.12.
//  Copyright (c) 2012 Greener Pastures. All rights reserved.
//

#import "UIViewController+CustomElements.h"
#import "NYKiPadSideMenuViewController.h"

#import "RemoteServiceStatus.h"
@implementation UIViewController (CustomElements)

- (void)setCustomBackButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[backBtn setImage:[UIImage imageNamed:@"iPad_backBtn.png"] forState:UIControlStateNormal];
	[backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
	backBtn.frame = CGRectMake( 0, 0, backBtn.imageView.image.size.width, backBtn.imageView.image.size.height );
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (UIBarButtonItem*)backButtonWithTarget:(id)target action:(SEL)action
{
	UIImage *image = [UIImage imageNamed:@"iPad_backBtn.png"];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:image forState:UIControlStateNormal];
	button.frame = CGRectMake( 0, 0, image.size.width, image.size.height );
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	// Wrap in UIBarButtonItem
	UIBarButtonItem *btnItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
	return btnItem;
}
 
- (void)setCustomTitle:(NSString*)title
{
	// Use custom font for title
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.adjustsFontSizeToFitWidth = NO;
	titleLabel.text = title;
	titleLabel.font = [UIFont fontWithName:@"FoundryFormSans-Medium" size:21];
	[titleLabel sizeToFit];

	self.navigationItem.titleView = titleLabel;
	[titleLabel release];
}

- (void)back
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (UIBarButtonItem*)settingsBarButtonWithTarget:(id)target action:(SEL)action
{
	UIImage *image = [UIImage imageNamed:@"iPad_btnSettings.png"];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake( 0, 0, image.size.width, image.size.height );
	
	// Wrap in UIBarButtonItem and return autoreleased
	UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	return [barBtnItem autorelease];
}

- (UIBarButtonItem*)menuBarButton
{
	UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *image = [UIImage imageNamed:@"iPad_menuButton.png"];
	[menuButton setImage:image forState:UIControlStateNormal];
	[menuButton addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
	menuButton.frame = CGRectMake( 0, 0, image.size.width, image.size.height );
	UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
	
	return [menuButtonItem autorelease];
}

- (UIBarButtonItem*)customBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
	UIImage *stretchableImage;
	if( [UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:)] )
		// iOS5+
		stretchableImage = [[UIImage imageNamed:@"iPad_customButtonBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake( 5, 5, 5, 5 )];
	else
		// pre-iOS 5
		stretchableImage = [[UIImage imageNamed:@"iPad_customButtonBg.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];

	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn setBackgroundImage:stretchableImage forState:UIControlStateNormal];
	[btn setTitle:title forState:UIControlStateNormal];
	[btn sizeToFit];
	CGRect frame = btn.frame;
	frame.size.width += 10;	// Increase width a bit to get some more space on either side of the text label
	frame.origin.y += 1;	// And move it a bit down
	btn.frame = frame;
	
	// Font
	btn.titleLabel.font = [UIFont fontWithName:@"FoundryFormSans-Demi" size:15];
	btn.titleLabel.textColor = [UIColor whiteColor];
	btn.titleLabel.shadowColor = RGB( 8, 24, 109 );
	btn.titleLabel.shadowOffset = CGSizeMake( 0, -1 );
	
	// Target and action
	[btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	// Wrap in UIBarButtonItem and return autoreleased
	UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	return [btnItem autorelease];
}

/* This method adjusts the width (crop rect) of the navigation bar background image so the image is centered
 * Call this method if you have are showing a navigation bar in a window that is narrower than usual (modally, e.g).
 * If you are manually adjusting the width of a modal window, call this method _after_ adjusting the frame size
 */
- (void)adjustNavigationBarImage
{
	// On iOS5, set the background image to a cropped version.
	// We don't need to do this for pre-iOS5, since the overridden drawRect method already takes different widths into account
	if( self.navigationController != nil && [UINavigationBar respondsToSelector:@selector(appearance)] )
	{
		// Get the default image
		UIImage *navbarImage = [UIImage imageNamed:@"iPad_navbar.png"];
		
		// Crop it from center to current width
		CGRect cropRect = CGRectMake( roundf( (navbarImage.size.width-self.navigationController.navigationBar.frame.size.width)/2 ), 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height );
		UIImage *croppedImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect( navbarImage.CGImage, cropRect )];
		
		// And set as background image
		[self.navigationController.navigationBar setBackgroundImage:croppedImage forBarMetrics:UIBarMetricsDefault];
	}
	

}

- (void)showSideMenu
{
	[NYKiPadSideMenuViewController showSideMenuInView:self.view];
}

- (void)goHomeBtn
{
    NSArray *viewControllers;        
    if([[RemoteServiceStatus sharedStatus]authorized]){
        viewControllers = [NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0], [self.navigationController.viewControllers objectAtIndex:1], nil];            
    }
    else{
        viewControllers = [NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0], nil];
    }
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

@end
