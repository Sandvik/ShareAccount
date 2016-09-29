//
//  ViewController.h
//  UIStepperDemo
//
//  Created by Uppal'z on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "NYKGeneralAccount.h"

@interface AccountUserSettingController : UIViewController<ADBannerViewDelegate>{
    ADBannerView *adView;
    BOOL bannerIsVisible;
    NYKGeneralAccount *user;
}
@property (nonatomic,retain) NYKGeneralAccount *user;
@property (strong, nonatomic) IBOutlet UIStepper *ourStepper;
@property (strong, nonatomic) IBOutlet UILabel *stepperValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic,assign) BOOL bannerIsVisible;
- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)backBtn:(id)sender;
-(void)loadInfoForCurrentRegnskab;

- (IBAction)changeFordelingForUser: (id) sender;
@end
