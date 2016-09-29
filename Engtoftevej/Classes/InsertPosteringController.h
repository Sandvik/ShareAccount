#import <UIKit/UIKit.h>
#import "RemoteController.h"
#import "NumberKeypadDecimalPoint.h"
#import <CoreLocation/CoreLocation.h>
#import "BrowseViewController.h"
#import "UIXOverlayController.h"

@class NYKKeyboardAvoidingScrollView;

@interface InsertPosteringController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,RemoteControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CLLocationManagerDelegate,UINavigationControllerDelegate> {

    NYKKeyboardAvoidingScrollView *scrollView;
    UITextField *price;
     UITextField *postnote;
    UITextField *type;
    //UITextField *person;
    UITextView *message;
    BOOL isNavigationBtn;
    UIButton *sendButton;
    RemoteController *remoteController;
    NumberKeypadDecimalPoint *numberKeyPad;
    UILabel *messageLbl;
    IBOutlet UILabel *messagePhotoLbl;
    IBOutlet UIPickerView *peoplePicker;
    IBOutlet UIPickerView *businessPicker;
    
    //Photo
    UIImage * selectedImage;
    UIButton * choosePhotoBtn;
	UIButton * takePhotoBtn;
    NSData *photo;
    
    //Location
    NSString *currentLatitude;
    NSString *currentLongitude;
    //AppDelegate *appDelegate;
    CLLocation *startLocation;
    BrowseViewController *parent;
    UIXOverlayController* uixOverlay;
}
@property (nonatomic,assign) BrowseViewController *parent;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) IBOutlet UIButton * choosePhotoBtn;
@property (nonatomic, retain) IBOutlet UIButton * takePhotoBtn;

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



@property (nonatomic, retain) UIPickerView *peoplePicker;
@property (nonatomic, retain) UIPickerView *businessPicker;
@property (nonatomic, retain) NumberKeypadDecimalPoint *numberKeyPad;
@property (nonatomic) BOOL isNavigationBtn;
@property (nonatomic, retain) IBOutlet NYKKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *price;
@property (nonatomic, retain) IBOutlet UITextField *postnote;

@property (nonatomic, retain) IBOutlet UITextView *message;
@property (nonatomic, retain) IBOutlet UITextField *type;
//@property (nonatomic, retain) IBOutlet UITextField *person;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UILabel *messageLbl;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *messagePhotoLbl;
- (IBAction)sendPostering:(id)sender;
- (IBAction)handleTaping;
-(IBAction) getPhoto:(id) sender;
- (void)quitView: (id) sender;
- (IBAction)dismissView:(id)sender;
-(void)uploadImage:(NSInteger)postid;
-(void)insertPostValue:(NSString*)person type:(NSString*)type pris:(NSString*)pris kvittering:(NSData *)kvittering postnote:(NSString *)postnote;
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeKeepingAspect:(CGSize)targetSize;
- (IBAction) showHelpOverlay:(id) sender;
@end