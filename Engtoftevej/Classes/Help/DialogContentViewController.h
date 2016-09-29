//
//  DialogContentViewController.h
//  UIXOverlayController
//
//  Created by Guy Umbright on 5/29/11.
//  Copyright 2011 Kickstand Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXOverlayController.h"
#import "CMPopTipView.h"

@interface DialogContentViewController : UIXOverlayContentViewController <CMPopTipViewDelegate> {
    NSMutableArray * muteArray;
    CGPoint closePostion;
}
@property (nonatomic, copy) NSMutableArray *muteArray;
@property (nonatomic) CGPoint closePostion;

- (IBAction) yesPressed:(id) sender;
- (IBAction) noPressed:(id) sender;
- (void)dismissAllPopTipViews;
- (IBAction) closeOverlayViev:(id) sender;
@end
