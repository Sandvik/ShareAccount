//
//  MainViewController.m
//  RSSReader
//
//  Created by Dean Collins on 5/04/09.
//  Copyright 2009 Big Click Studios. All rights reserved.
//

#import "MainViewController.h"
#import "BrowseViewController.h"
//#import "SettingViewController.h"
#import "SpringViewController.h"
#import "AccountingViewController.h"
#import "InsertPosteringController.h"

@implementation MainViewController

@synthesize navigationController;

- (void)viewDidLoad {
	[super viewDidLoad];
    
	//NSLog(@"Main View Did Load: %@", self.tabBarItem.title);
    
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) //iOS >=5.0
    {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed: @"background.png"] forBarMetrics:UIBarMetricsDefault];        
    }else{
        [[self.navigationController navigationBar] setTintColor:[UIColor orangeColor] ];
        
    }
    //navigationController = [[UINavigationController alloc]init];
    //[[navigationController navigationBar] setTintColor:[UIColor blueColor] ];
	if(self.tabBarItem.title == @"Postings") {
		SpringViewController *browseViewController = [[SpringViewController alloc] init];
		[self pushViewController:browseViewController animated:YES];
		[browseViewController release];
	} 
//    else if (self.tabBarItem.title == @"Most Recent") {	
//		RecentViewController *recentViewController = [[RecentViewController alloc] init];
//		[self pushViewController:recentViewController animated:YES];
//		[recentViewController release];
//	} 
    else if (self.tabBarItem.title == @"") {
        InsertPosteringController* vc = [[InsertPosteringController alloc] initWithNibName:@"ContactForm" bundle:nil];  
        [self pushViewController:vc animated:YES];
		[vc release];
	} 
    else if (self.tabBarItem.title == @"Accounting") {	
		AccountingViewController* vc = [[AccountingViewController alloc] initWithNibName:@"Accounting" bundle:nil];  
        [self pushViewController:vc animated:YES];
		[vc release];
	}
//    else if (self.tabBarItem.title == @"Info") {	
//		SettingViewController *vc = [[SettingViewController alloc] initWithNibName:@"Setting" bundle:nil];  
//        [self pushViewController:vc animated:YES];
//		[vc release];
//	}
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
	[navigationController release];
}


@end
