//
//  ViewController.h
//  SESpringBoardDemo
//
//  Created by Sarp Erdag on 11/5/11.
//  Copyright (c) 2011 Sarp Erdag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseViewController.h"
#import "CreateRegnskabController.h"
#import "RemoteController.h"
//#import "CMPopTipView.h"
#import "UIXOverlayController.h"

@interface SpringViewController : UIViewController<RemoteControllerDelegate>{
    RemoteController *remoteController;
    //AppDelegate *appDelegate;
    
    IBOutlet UIView *loginCreateView;
    IBOutlet UIButton *loginButton;
    BOOL openCreateView;
    IBOutlet UIView *splashView;
    IBOutlet UILabel *currentUser;
    UIXOverlayController* uixOverlay;
}
@property (nonatomic) BOOL openCreateView;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UILabel *currentUser;
@property(nonatomic, retain) BrowseViewController *vc1;
@property(nonatomic, retain) CreateRegnskabController *vc3;
@property(nonatomic, retain) UIViewController *vc2;

@property (nonatomic, retain) IBOutlet UIView *splashView;
@property (nonatomic, retain) IBOutlet UIView *loginCreateView;
-(void)loadRegnskabForPerson;
- (void)loadRegnskabForPersonHandler: (NSNotification *) notification;
- (void)hideCreateView: (NSNotification *) notification;
- (void)unHideCreateView: (NSNotification *) notification;
- (IBAction)openLoginCreateView: (id) sender;
- (IBAction)closeLoginCreateView:(id)sender;
-(void)closeLoginCreateView;
-(void)openLoginCreateView;
-(IBAction)createBruger:(id)sender;
-(void)loadInvitationsForPerson;
-(void)addPersonToRegnskabAfterInvite:(NSInteger)regnskab;
-(void)deleteinviteToRegnskab:(NSInteger)regnskab;
-(IBAction)loginBruger:(id)sender;
-(void)loadUser:(NSString*)ident;
- (IBAction) showHelpOverlay:(id) sender;
- (IBAction) logoutBruger:(id) sender;
@end
