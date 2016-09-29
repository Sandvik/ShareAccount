#import <UIKit/UIKit.h>
#import "RemoteController.h"
#import "NumberKeypadDecimalPoint.h"
#import <CoreLocation/CoreLocation.h>
#import "SpringViewController.h"

@class NYKKeyboardAvoidingScrollView;

@interface LoginAccount : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,RemoteControllerDelegate,CLLocationManagerDelegate,UINavigationControllerDelegate> {

    NYKKeyboardAvoidingScrollView *scrollView;
    UITextField *emailAdresse;
    UITextField *password;
    UITextField *username;
    UITextField *fuldtNavn;
    UITextView *message;
    BOOL isNavigationBtn;
    UIButton *sendButton;
    RemoteController *remoteController;
    UILabel *messageLbl;
    IBOutlet UILabel *messagePhotoLbl;
    
    //Photo
    UIImageView * selectedImage;
    UIButton * choosePhotoBtn;
	UIButton * takePhotoBtn;
    NSData *photo;
    
    //Location
    NSString *currentLatitude;
    NSString *currentLongitude;
//    UILabel *latitudeLbl;
//    UILabel *longitudeLbl;
//    UILabel *horizontalAccuracy;
//    UILabel *altitude;
//    UILabel *verticalAccuracy;
//    UILabel *distance;
//    UIButton *resetButton;
    CLLocation *startLocation;
    SpringViewController *parent;
    
    UIButton * loginButton;
	UIButton * cancelButton;
}
@property (nonatomic,assign) SpringViewController *parent;
@property (nonatomic, retain) IBOutlet UIImageView *selectedImage;
@property (nonatomic, retain) IBOutlet UIButton * choosePhotoBtn;
@property (nonatomic, retain) IBOutlet UIButton * takePhotoBtn;

@property (nonatomic, retain) IBOutlet UIButton * loginButton;
@property (nonatomic, retain) IBOutlet UIButton * cancelButton;

//Lokation
@property (nonatomic, retain) CLLocationManager *locationManager;
//@property (nonatomic, retain) IBOutlet UILabel *latitudeLbl;
//@property (nonatomic, retain) IBOutlet UILabel *longitudeLbl;
@property (nonatomic, retain)   NSString *currentLatitude;
@property (nonatomic, retain)   NSString *currentLongitude;
@property (nonatomic, retain)   NSData *photo;
//@property (nonatomic, retain) IBOutlet UILabel *horizontalAccuracy;
//@property (nonatomic, retain) IBOutlet UILabel *verticalAccuracy;
//@property (nonatomic, retain) IBOutlet UILabel *altitude;
//@property (nonatomic, retain) IBOutlet UILabel *distance;
@property (nonatomic, retain) CLLocation *startLocation;

@property (nonatomic) BOOL isNavigationBtn;
@property (nonatomic, retain) IBOutlet NYKKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *emailAdresse;
@property (nonatomic, retain) IBOutlet UITextField *fuldtNavn;
@property (nonatomic, retain) IBOutlet UITextView *message;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UILabel *messageLbl;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *messagePhotoLbl;
- (IBAction)gemUserData:(id)sender;
- (IBAction)handleTaping;
-(IBAction) getPhoto:(id) sender;
-(IBAction)closeMe:(id)sender;
-(void)loginUser:(NSString*)user password:(NSString*)password;

@end
