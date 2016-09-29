//
//  SESpringBoard.m
//  SESpringBoardDemo
//
//  Created by Sarp Erdag on 11/5/11.
//  Copyright (c) 2011 Sarp Erdag. All rights reserved.
//

#import "SESpringBoard.h"
#import "SEViewController.h"
#import "CreateRegnskabController.h"
#import "BrowseViewController.h"
#import "AppDataCache.h"
@implementation SESpringBoard

@synthesize items, title, launcher, isInEditingMode, itemCounts;
@synthesize itemsContainer;
@synthesize bannerIsVisible;

static SESpringBoard *sharedSESpringBoard;

+ (SESpringBoard *)sharedSESpringBoard{
	@synchronized(self) {
		if(sharedSESpringBoard==nil) {
			sharedSESpringBoard = [[SESpringBoard alloc] initWithData:@"Accounting" items:nil image:[UIImage imageNamed:@"Sites-icon.png"]];
        }
    }
    return sharedSESpringBoard;
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"HEELÆKJHÆSDLjhsælkjdh");
}

- (IBAction) doneEditingButtonClicked {
    [self disableEditingMode];
}


- (id) initWithData:(NSString *)boardTitle items:(NSMutableArray *)menuItems image:(UIImage *) image{
    
    self = [super initWithFrame:CGRectMake(0, 0, 320, 460)];
    
    UIView *adbackgrounf = [[UIView alloc] initWithFrame:CGRectMake(0,50,320,50)];
    adbackgrounf.backgroundColor = [UIColor clearColor];
    [self addSubview:adbackgrounf];
    
    UILabel *adlabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 50, 320, 45)];
    adlabel.numberOfLines = 2;
    adlabel.backgroundColor = [UIColor clearColor];
    adlabel.font = [UIFont fontWithName:@"Verdana" size:11];
    adlabel.textColor = [UIColor whiteColor];
    adlabel.text = @"Help us keep development costs down by tapping these advertisements";
    adlabel.textAlignment = UITextAlignmentLeft;
    [self addSubview:adlabel];
    
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, 0, -50);
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    [self addSubview:adView];
    adView.delegate=self;
    self.bannerIsVisible=NO;
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0,95,320,5)];
    divider.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [self addSubview:divider];
    
   
    
    adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait,ADBannerContentSizeIdentifierLandscape,nil];

    
    // self.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
    
    [self setUserInteractionEnabled:YES];
    if (self) {
        self.launcher = image;
        self.isInEditingMode = NO;
        
        // create the top bar
        self.title = boardTitle;
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
        {
            [navigationBar setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];        
        }else{
            [navigationBar setTintColor:[UIColor orangeColor] ];
            
        }
        
        // add a simple for displaying a title on the bar
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [titleLabel setText:title];
        [navigationBar addSubview:titleLabel];
        [titleLabel release];
        
        // add a button to the right side that will become visible when the items are in editing mode
        // clicking this button ends editing mode for all items on the springboard
        doneEditingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        doneEditingButton.frame = CGRectMake(265, 5, 50, 34.0);
        [doneEditingButton setTitle:@"Done" forState:UIControlStateNormal];
        doneEditingButton.backgroundColor = [UIColor clearColor];
        [doneEditingButton addTarget:self action:@selector(doneEditingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [doneEditingButton setHidden:YES];
        [navigationBar addSubview:doneEditingButton];
        
        [self addSubview:navigationBar];
        
        // create a container view to put the menu items inside
        itemsContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 100, 300, 400)];
        itemsContainer.delegate = self;
        [itemsContainer setScrollEnabled:YES];
        [itemsContainer setPagingEnabled:YES];
        itemsContainer.showsHorizontalScrollIndicator = NO;
        [self addSubview:itemsContainer];
        //[self.items removeAllObjects];
        
        self.items = menuItems;
        
        //NSLog(@"%@",self.items);
        
        int counter = 0;
        int horgap = 0;
        int vergap = 0;
        int numberOfPages = (ceil((float)[menuItems count] / 12));
        int currentPage = 0;
        for (SEMenuItem *item in self.items) {
            currentPage = counter / 12;
            item.tag = counter;
            item.delegate = self;
            [item setFrame:CGRectMake(item.frame.origin.x + horgap + (currentPage*300), item.frame.origin.y + vergap, 100, 100)];
            [itemsContainer addSubview:item];
            horgap = horgap + 100;
            counter = counter + 1;
            if(counter % 3 == 0){
                vergap = vergap + 95;
                horgap = 0;
            }
            if (counter % 12 == 0) {
                vergap = 0;
            }
        }
        
        // record the item counts for each page
        self.itemCounts = [NSMutableArray array];
        int totalNumberOfItems = [self.items count];
        int numberOfFullPages = totalNumberOfItems % 12;
        int lastPageItemCount = totalNumberOfItems - numberOfFullPages%12;
        for (int i=0; i<numberOfFullPages; i++)
            [self.itemCounts addObject:[NSNumber numberWithInteger:12]];
        if (lastPageItemCount != 0)
            [self.itemCounts addObject:[NSNumber numberWithInteger:lastPageItemCount]];
        
        [itemsContainer setContentSize:CGSizeMake(numberOfPages*300, itemsContainer.frame.size.height)];
        [itemsContainer release];
        
        // add a page control representing the page the scrollview controls
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 433, 320, 20)];
        //NSLog(@"%d",pageControl.currentPage);
        if (numberOfPages > 1) {
            pageControl.numberOfPages = numberOfPages;
            pageControl.currentPage = 0;
            [self addSubview:pageControl];
        }
        
        // add listener to detect close view events
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(closeViewEventHandler:)
         name:@"closeView"
         object:nil ];
    }
    //NSLog(@"%@",self.itemCounts);
    return self;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
        banner.frame = CGRectOffset(banner.frame, 0, 95);
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
    //NSLog(@"Banner view is beginning an ad action");
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

//+ (id) initWithTitle:(NSString *)boardTitle items:(NSMutableArray *)menuItems launcherImage:(UIImage *)image {
//    SESpringBoard *tmpInstance = [[[SESpringBoard alloc] initWithData:boardTitle items:menuItems image:image] autorelease];
//	return tmpInstance;
//};


- (void)dealloc {
    [items release];
    [launcher release];
    [navigationBar release];
    [pageControl release];
    [itemCounts release];
    adView.delegate=nil;
    [adView release];
    [super dealloc];
}

// transition animation function required for the springboard look & feel
- (CGAffineTransform)offscreenQuadrantTransformForView:(UIView *)theView {
    CGPoint parentMidpoint = CGPointMake(CGRectGetMidX(theView.superview.bounds), CGRectGetMidY(theView.superview.bounds));
    CGFloat xSign = (theView.center.x < parentMidpoint.x) ? -1.f : 1.f;
    CGFloat ySign = (theView.center.y < parentMidpoint.y) ? -1.f : 1.f;
    return CGAffineTransformMakeTranslation(xSign * parentMidpoint.x, ySign * parentMidpoint.y);
}

#pragma mark - MenuItem Delegate Methods

- (void)launch:(int)tag :viewController {
    
    // if the springboard is in editing mode, do not launch any view controller
    if (isInEditingMode)
        return;
    
    // first disable the editing mode so that items will stop wiggling when an item is launched
    [self disableEditingMode];
    
    // create a navigation bar
    nav = [UINavigationController alloc];
    
    
    if ([viewController isKindOfClass:[CreateRegnskabController class]]) {
        //        //NSLog(@"YES");
        //        
        CreateRegnskabController* vc = [[CreateRegnskabController alloc] initWithNibName:@"CreateRegnskab" bundle:nil];
        [vc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        [SharedAppDelegate.tabBarController presentModalViewController:vc animated:YES];
        [vc release];
        
        //        viewController.view.backgroundColor = [UIColor clearColor];
        //        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        //        [rootViewController presentModalViewController:viewController animated:YES];
        
    }
    else {
        
        
        SEViewController *vc = viewController;
        
        // manually trigger the appear method
        [viewController viewDidAppear:YES];
        
        vc.launcherImage = launcher;
        [nav initWithRootViewController:viewController];
        [nav viewDidAppear:YES];
        
        nav.view.alpha = 0.f;
        nav.view.transform = CGAffineTransformMakeScale(.1f, .1f);
        [self addSubview:nav.view];
        
        [UIView animateWithDuration:.3f  animations:^{
            // fade out the buttons
            for(SEMenuItem *item in self.items) {
                item.transform = [self offscreenQuadrantTransformForView:item];
                item.alpha = 0.f;
            }
            
            // fade in the selected view
            nav.view.alpha = 1.f;
            nav.view.transform = CGAffineTransformIdentity;
            [nav.view setFrame:CGRectMake(0,0, self.bounds.size.width, self.bounds.size.height)];
            
            // fade out the top bar
            [navigationBar setFrame:CGRectMake(0, -44, 320, 44)];
        }];
    }
}
-(void)add2FromSpringboard:(SEMenuItem*)item{
    //Clean all
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (SEMenuItem *obj in self.items) {
        if (obj != [self.items lastObject]) {
            SEMenuItem *gg = [SEMenuItem initWithTitle:obj.titleText imageName:obj.image viewController:obj.vcToLoad removable:YES];
            [array addObject:gg]; 
        }      
    }    
    //Putter nyeste item på ligefør regnskabsikon
    [array addObject:item];
    
    //Finde regnskabsikon
    SEMenuItem *last =[self.items lastObject];
    SEMenuItem *ggLast = [SEMenuItem initWithTitle:last.titleText imageName:last.image viewController:last.vcToLoad removable:NO];
    [array addObject:ggLast];
    
    
    //Fjerner alle de gamle items fra view
    [itemsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.items = array;    
    
    //NSLog(@"%@",self.items);
    
    int counter = 0;
    int horgap = 0;
    int vergap = 0;
    int numberOfPages = (ceil((float)[self.items count] / 12));
    int currentPage = 0;
    for (SEMenuItem *item in self.items) {
        currentPage = counter / 12;
        item.tag = counter;
        item.delegate = self;
        [item setFrame:CGRectMake(item.frame.origin.x + horgap + (currentPage*300), item.frame.origin.y + vergap, 100, 100)];
        [itemsContainer addSubview:item];
        horgap = horgap + 100;
        counter = counter + 1;
        if(counter % 3 == 0){
            vergap = vergap + 95;
            horgap = 0;
        }
        if (counter % 12 == 0) {
            vergap = 0;
        }
    }
    
    // record the item counts for each page
    self.itemCounts = [NSMutableArray array];
    int totalNumberOfItems = [self.items count];
    int numberOfFullPages = totalNumberOfItems % 12;
    int lastPageItemCount = totalNumberOfItems - numberOfFullPages%12;
    for (int i=0; i<numberOfFullPages; i++)
        [self.itemCounts addObject:[NSNumber numberWithInteger:12]];
    if (lastPageItemCount != 0)
        [self.itemCounts addObject:[NSNumber numberWithInteger:lastPageItemCount]];
    
    [itemsContainer setContentSize:CGSizeMake(numberOfPages*300, itemsContainer.frame.size.height)];
    //[itemsContainer release];
    
    // add a page control representing the page the scrollview controls
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 433, 320, 20)];
    if (numberOfPages > 1) {
        pageControl.numberOfPages = numberOfPages;
        pageControl.currentPage = 0;
        [self addSubview:pageControl];
    }
    
}

- (void)removeFromSpringboard:(int)index {
    
    UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Delete account"];
	[alert setMessage:@"Do you really want to delete this account?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
    alert.tag=index;
	[alert show];
	[alert release];

   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        
        // Remove the selected menu item from the springboard, it will have a animation while disappearing
        SEMenuItem *menuItem = [items objectAtIndex:alertView.tag];
        
        //NSLog(@"%@",menuItem.titleText);
        [menuItem removeFromSuperview];
        //NSLog(@"%d",[self.itemCounts count]);
        //NSLog(@"%@",self.itemCounts);
        //NSLog(@"%d",pageControl.currentPage);
        //    int numberOfItemsInCurrentPage = [[self.itemCounts objectAtIndex:pageControl.currentPage] intValue];
        //    
        //    // First find the index of the current item with respect of the current page
        //    // so that only the items coming after the current item will be repositioned.
        //    // The index of the item can be found by looking at its coordinates
        //    int mult = ((int)menuItem.frame.origin.y) / 95;
        //    int add = ((int)menuItem.frame.origin.x % 300)/100;
        //    int pageSpecificIndex = (mult*3) + add;
        //    int remainingNumberOfItemsInPage = numberOfItemsInCurrentPage-pageSpecificIndex;    
        //    
        //    // Select the items listed after the deleted menu item
        //    // and move each of the ones on the current page, one step back.
        //    // The first item of each row becomes the last item of the previous row.
        //    for (int i = index+1; i<[items count]; i++) {
        //        SEMenuItem *item = [items objectAtIndex:i];   
        //        [UIView animateWithDuration:0.2 animations:^{
        //            
        //            // Only reposition the items in the current page, coming after the current item
        //            if (i < index + remainingNumberOfItemsInPage) {
        //                
        //                int intVal = item.frame.origin.x;
        //                // Check if it is the first item in the row
        //                if (intVal % 3 == 0)
        //                    [item setFrame:CGRectMake(item.frame.origin.x+200, item.frame.origin.y-95, item.frame.size.width, item.frame.size.height)];
        //                else 
        //                    [item setFrame:CGRectMake(item.frame.origin.x-100, item.frame.origin.y, item.frame.size.width, item.frame.size.height)];
        //            }            
        //            
        //            // Update the tag to match with the index. Since the an item is being removed from the array, 
        //            // all the items' tags coming after the current item has to be decreased by 1.
        //            [item updateTag:item.tag-1];
        //        }]; 
        //    }
        // remove the item from the array of items
        NSInteger idregn;
        NSInteger regnskaboprettetAf;
        
        if ([menuItem.vcToLoad isKindOfClass:[BrowseViewController class]]) {
            BrowseViewController *controller =(BrowseViewController*)menuItem.vcToLoad;
            idregn = controller.regnskabsid;
            regnskaboprettetAf= controller.oprettetAfPerson;
            //NSLog(@"%d",idregn);
        }
        [items removeObjectAtIndex:alertView.tag];
        
        if(remoteController==nil) {
            remoteController = [[RemoteController alloc] init];
            remoteController.delegate = self;
        }
        
        //Hvis brugeren er dén som har oprettet regnskab må han også gerne slette det
        if (regnskaboprettetAf == [AppDataCache sharedAppDataSource].currentUserId) {
            [self getAllePosteringsIdenter:idregn];
             [remoteController deleteRegnskab:idregn];
        }else {
            //HVis han ikke har oprettet det må han kun slette sin association med det, dvs sine posteringer og deltagelse i regnskab
            [remoteController deleteRegnskabAssociation:idregn];
        }
       
        
        // also decrease the record of the count of items on the current page and save it in the array holding the data
        // numberOfItemsInCurrentPage--;
        //[self.itemCounts replaceObjectAtIndex:pageControl.currentPage withObject:[NSNumber numberWithInteger:numberOfItemsInCurrentPage]];
	}
	else if (buttonIndex == 1)
	{
		// No
	}
}

//Henter lige alle identer på posteringer før de slettes, så vi senere kan slette billderne
-(void)getAllePosteringsIdenter:(NSInteger)regnskabsid{
    
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];
	
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/indexKlunse.php?ident='%d'",regnskabsid];
    [urlStr appendString:mytmp];
    
    //NSLog(@"urlStr: %@",urlStr);
    
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
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            //NSLog(@"SpendingData %@", jsonString);
            NSDictionary *json = [jsonString JSONValue];
            //NSLog(@"%d",[json count]);
            [[AppDataCache sharedAppDataSource].posteringerNumbersList removeAllObjects];
            NSLog(@"json %@", json);
            
            for (NSDictionary *status in json){
               
                NSNumber *tt = [NSNumber numberWithInteger:[[status valueForKey:@"id"] intValue]];
                [[AppDataCache sharedAppDataSource].posteringerNumbersList addObject:tt];
            }           
        }
    }];
}


- (void)closeViewEventHandler: (NSNotification *) notification {
    UIView *viewToRemove = (UIView *) notification.object;    
    [UIView animateWithDuration:.3f animations:^{
        viewToRemove.alpha = 0.f;
        viewToRemove.transform = CGAffineTransformMakeScale(.1f, .1f);
        for(SEMenuItem *item in self.items) {
            item.transform = CGAffineTransformIdentity;
            item.alpha = 1.f;
        }
        [navigationBar setFrame:CGRectMake(0, 0, 320, 44)];
    } completion:^(BOOL finished) {
        [viewToRemove removeFromSuperview];
    }];
    
    // release the dynamically created navigation bar
    //[nav release];
    [SharedAppDelegate hideTabBar];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = itemsContainer.frame.size.width;
    int page = floor((itemsContainer.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

#pragma mark - Custom Methods

- (void) disableEditingMode {
    // loop thu all the items of the board and disable each's editing mode
    for (SEMenuItem *item in items)
        [item disableEditing];
    
    [doneEditingButton setHidden:YES];
    self.isInEditingMode = NO;
}

- (void) enableEditingMode {
    
    for (SEMenuItem *item in items)
        [item enableEditing];
    
    // show the done editing button
    [doneEditingButton setHidden:NO];
    self.isInEditingMode = YES;
}

@end
