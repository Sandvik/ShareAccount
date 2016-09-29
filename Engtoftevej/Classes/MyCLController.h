
#import <CoreLocation/CoreLocation.h>

// This protocol is used to send the text for location updates back to another view controller
@protocol SRPostionDelegate <NSObject>
@required
-(void)newLocationUpdate:(CLLocation *)location;
@optional
-(void)newError:(NSString *)text;
-(void)textLocationUpdate:(NSString *)theCity;
-(void) didUpdateHeading:(double )newHeading;

@end

@protocol MyCLPositionDelegate <NSObject>
@optional
-(void)doPostionReleatedMethods:(CLLocation *)location;
@end

// Class definition
@interface MyCLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	id delegate;
	id positiondelegate;
	CLLocation *theLocation;
	NSMutableData *receivedData;
	NSMutableString *locationAsText;
	bool foundLocation;
	BOOL locationAvailable;
	BOOL startedLocationLookup;
	NSURLConnection *theConnection;
}
@property (nonatomic, retain) NSURLConnection *theConnection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableString *locationAsText;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *theLocation;
@property (nonatomic,assign) id <SRPostionDelegate> delegate;
@property (nonatomic,assign) id <MyCLPositionDelegate> positiondelegate;

- (void)loadLocationAsText;


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

+ (MyCLController *)sharedInstance;

@end

