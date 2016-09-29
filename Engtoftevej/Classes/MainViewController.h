//
//  MainViewController.h
//  RSSReader
//
//  Created by Dean Collins on 5/04/09.
//  Copyright 2009 Big Click Studios. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainViewController : UINavigationController {
	UINavigationController *navigationController;
    //AppDelegate *appDelegate;
}

@property (nonatomic, retain) UINavigationController *navigationController;

@end
