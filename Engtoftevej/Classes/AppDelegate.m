#import "AppDelegate.h"
#import "MainViewController.h"
#import "SpringViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;

@synthesize moneyBtn;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    moneyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[moneyBtn addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    moneyBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    moneyBtn.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [moneyBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [moneyBtn setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - tabBarController.tabBar.frame.size.height;
    if (heightDifference < 0)
        moneyBtn.center = tabBarController.tabBar.center;
    else
    {
        CGPoint center = tabBarController.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        moneyBtn.center = center;
    }
    moneyBtn.enabled=NO;
    moneyBtn.hidden=YES;
   
    [tabBarController.view addSubview:moneyBtn];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
   
//    MainViewController *viewController0 = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//	UITabBarItem* tabBarItem0 =  [[UITabBarItem alloc] initWithTitle:@"Forside" image:[UIImage imageNamed:@"tab_feed.png"] tag:8];
//    tabBarItem0.enabled = NO;
//    viewController0.tabBarItem =tabBarItem0;
//    [tabBarItem0 release]; 
    
    SpringViewController *viewController1  = [[SpringViewController alloc] init];
    UITabBarItem* tabBarItem =  [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:9];
    tabBarItem.enabled = NO;
    viewController1.tabBarItem =tabBarItem;
    [tabBarItem release];
    //viewController1.tabBarItem.title = @"Posteringer";
    //viewController1.tabBarItem.enabled = NO;
	
//    MainViewController *viewController1 = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//	viewController1.tabBarItem.title = @"Posteringer";
//	
    MainViewController *viewController2 = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	viewController2.tabBarItem.title = @"";
    viewController2.tabBarItem.enabled = NO;

	MainViewController *viewController4 = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	UITabBarItem* tabBarItem2 =  [[UITabBarItem alloc] initWithTitle:@"Info" image:[UIImage imageNamed:@"tab_live.png"] tag:8];
    tabBarItem2.enabled = YES;
    viewController4.tabBarItem =tabBarItem2;
    [tabBarItem2 release];   
    
//    MainViewController *viewController5 = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//	UITabBarItem* tabBarItem5 =  [[UITabBarItem alloc] initWithTitle:@"About" image:[UIImage imageNamed:@"tab_feed.png"] tag:8];
//    tabBarItem5.enabled = NO;
//    viewController5.tabBarItem =tabBarItem5;
//    [tabBarItem5 release];   
	
    tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1,viewController2,viewController4, nil];
	
    [self addCenterButtonWithImage:[UIImage imageNamed:@"Smiley-sleep-icon.png"] highlightImage:[UIImage imageNamed:@"Smiley-dollar-icon.png"]];
    
	// Add the tab bar controller's current view as a subview of the window
   // [window addSubview:tabBarController.view];
    // Override point for customization after application launch
    
    
    [window setRootViewController:tabBarController];
    [window makeKeyAndVisible];
    //[self showSplash];
    //[self setAppearance];
    
    //Checker om Icloud er tilgængelig
//    NSURL *ubiq = [[NSFileManager defaultManager]
//                   URLForUbiquityContainerIdentifier:nil];
//    if (ubiq) {
//        NSLog(@"iCloud access at %@", ubiq);
//        // TODO: Load document...
//    } else {
//        NSLog(@"No iCloud access");
//    }
    
    // Register user defaults
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:
									[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
	
}
- (void)setAppearance
{
	// iOS 5 only
	if( [UINavigationBar respondsToSelector:@selector(appearance)] )
	{
		        // iPhone
		if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];
            
        }
	}
}

- (void)showSplash
{
	UIImageView *splashImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash.png"]] autorelease];
	[self.window addSubview:splashImageView];
	CGRect frame = splashImageView.frame;
	frame = CGRectInset( frame, -frame.size.width, -frame.size.height );	// Expand frame
	
	[UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
        //    splashImageView.frame = frame; 
        splashImageView.alpha=0;
    } completion:^(BOOL finished){[splashImageView removeFromSuperview];}];
}

- (void) hideTabBar {
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    for(UIView *view in tabBarController.view.subviews)
    {
       NSLog(@"%@", view);
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
        } 
        else if([view isKindOfClass:[UIButton class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
        } 
        else 
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
        }
        
    }
    
    [UIView commitAnimations];    
}

- (void) showTabBar{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    for(UIView *view in tabBarController.view.subviews)
    {
        NSLog(@"%@", view);
         
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            
        } 
        else if([view isKindOfClass:[UIButton class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 421, view.frame.size.width, view.frame.size.height)];
        } 
        else 
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
        }
        
        
    }
    
    [UIView commitAnimations]; 
}



- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    //Save all the dirty coffee objects and free memory.
	//[self.coffeeArray makeObjectsPerformSelector:@selector(saveAllData)];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
	
	[tabBarController release];
	[window release];
  	[super dealloc];
}




@end
