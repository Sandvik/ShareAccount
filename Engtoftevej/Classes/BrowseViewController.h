#import <UIKit/UIKit.h>
#import "RemoteController.h"
#import "SEViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SMContactsSelector.h"
#import <iAd/iAd.h>
#import "MKNumberBadgeView.h"
#import "UIXOverlayController.h"

@interface BrowseViewController : SEViewController<RemoteControllerDelegate,SMContactsSelectorDelegate,UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,ADBannerViewDelegate> {
	
	//AppDelegate *appDelegate;
	RemoteController *remoteController;

	UINavigationController *addNavigationController;
    UIButton *editButton;
    NSInteger regnskabsid;
    NSInteger oprettetAfPerson;
    IBOutlet UIButton* smsButton;
    IBOutlet UIButton* mailButton;
    IBOutlet UIView *letEmKnowView;
    BOOL isOpenLetEmKnowView;
    NSMutableArray *recipients;
    IBOutlet UITableView* accountInfoTable; 
    
    ADBannerView *adView;
    BOOL bannerIsVisible;
    NSString *regnskabsnavn;
    MKNumberBadgeView * badgeview;
    MKNumberBadgeView * badgeview2;
    UIXOverlayController* uixOverlay;
}
@property (nonatomic, retain) MKNumberBadgeView * badgeview2;
@property (nonatomic, retain) MKNumberBadgeView * badgeview;
@property (nonatomic, copy) NSString *regnskabsnavn;
@property (nonatomic,assign) BOOL bannerIsVisible;
@property (nonatomic, retain) UITableView* accountInfoTable;
@property (nonatomic, retain) NSMutableArray *recipients;
@property (nonatomic) BOOL isOpenLetEmKnowView;
@property (nonatomic, retain) IBOutlet UIView *letEmKnowView;
@property (retain)UIButton* smsButton;
@property (retain)UIButton* mailButton;

@property (retain, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIView *myView;
@property (nonatomic, retain) UIButton *editButton;
@property (assign) NSInteger regnskabsid;
@property (assign) NSInteger oprettetAfPerson;

-(void)loadInfoOmFordelingiRegnskab;
- (void) loadRegnskab;
- (IBAction)showModalPanel:(id)sender;
- (IBAction)closeContact:(id)sender;
-(void)closeContact;
-(void)loadInfoForCurrentRegnskab;
-(void)invitePeopleToCurrentRegnskab:(NSString*)email;
- (void)quitView: (id) sender;

-(IBAction)smsButtonClicked;
//-(IBAction)mailButtonClicked;
-(IBAction)multiSelectorContactsButtonClicked;
- (void)sendSMS:(NSString *)bodyOfMessage;
//-(void)displayComposerSheet;
//-(void)launchMailAppOnDevice;
- (void)closeThisViewNotification: (NSNotification *) notification;
- (IBAction)openLetEmKnowView: (id) sender;
-(void)openLetEmKnowView;
-(UIImage*)findRelevantImage:(NSString*)type;
-(void)getMessageCount;
- (IBAction) showHelpOverlay:(id) sender;

@end
