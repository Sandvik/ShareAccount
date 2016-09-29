//
//  SettingsViewController.h
//  RSSReader
//
//  Created by Dean Collins on 5/04/09.
//  Copyright 2009 Big Click Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteController.h"
#import <iAd/iAd.h>
#import "UIXOverlayController.h"

@class NYKKeyboardAvoidingScrollView;
@interface AccountingViewController :UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, UITextViewDelegate,RemoteControllerDelegate,ADBannerViewDelegate> {
    AppDelegate *appDelegate;
    NYKKeyboardAvoidingScrollView *scrollView;
    UITextField *name;
    UITextField *adresse;
    UITextField *postnr_by;
    UITextField *tlfNummer;
    UITextField *email;
    UITextView *message;
    BOOL isNavigationBtn;
   
    
    UILabel *balanceLabel;
    UILabel *prefLabel;
    UISegmentedControl *segmentControl;
    NSString *contactPref;
    RemoteController *remoteController;
    IBOutlet UITableView* accountTable; 
    IBOutlet UIView *myView;
    BOOL isOpenLetEmKnowView;
    
    BOOL showFinishedAccountings;
    ADBannerView *adView;
    BOOL bannerIsVisible;
    UIButton * showAccountingsBtn;
    UIXOverlayController* uixOverlay;
    
@private
    NSIndexPath* _openedCellIndexPath;
}

@property (nonatomic, retain) IBOutlet UIButton * showAccountingsBtn;
@property (nonatomic,assign) BOOL bannerIsVisible;
@property (nonatomic, retain) NSIndexPath* openedCellIndexPath;
@property (nonatomic) BOOL isOpenLetEmKnowView;
@property (nonatomic) BOOL showFinishedAccountings;
@property (nonatomic, retain) IBOutlet UIView *myView;
@property (nonatomic, retain) UITableView* accountTable;
@property (nonatomic) BOOL isNavigationBtn;
@property (nonatomic, retain) IBOutlet NYKKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, retain) IBOutlet NSString *contactPref;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextView *message;
@property (nonatomic, retain) IBOutlet UITextField *adresse;
@property (nonatomic, retain) IBOutlet UITextField *postnr_by;
@property (nonatomic, retain) IBOutlet UITextField *tlfNummer;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UILabel *balanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *prefLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)openLetEmKnowView: (id) sender;
- (void)beregnSendRegnskab;
-(void)beregnNow;
- (IBAction) segmentedControlDidChange:(id) sender;

-(IBAction) beregnogsend_BtnAction:(id) sender;
-(IBAction) sealleregnskab_BtnAction:(id) sender;
- (void)quitView: (id) sender;
- (void)closeOpenedCell;
- (IBAction) showHelpOverlay:(id) sender;
-(BOOL)erProcentLigelig;
-(void)updateRegnskab:(NSDate*)fraDato tildato:(NSDate*)tildato regnskab:(NSString*)regnskab status:(NSString*)status;
@end
