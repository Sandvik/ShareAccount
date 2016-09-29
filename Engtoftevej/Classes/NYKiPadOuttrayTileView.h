//
//  NYKiPadAccountTileView.h
//  MitNykredit
//
//  Created by Jens Willy Johannsen on 31-01-12.
//  Copyright (c) 2012 Nykredit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataCache.h"
#import "RemoteController.h"

@interface NYKiPadOuttrayTileView : UIView <RemoteControllerDelegate>
{
	RemoteController *remoteServiceController;
}

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *balanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalLabel;
@property (retain, nonatomic) IBOutlet UIView *transactionsView;
@property (retain, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (retain, nonatomic) IBOutlet UIView *dividerView;
@property (retain, nonatomic) IBOutlet UIView *dividerViewBalance;

- (void)handleTap:(UITapGestureRecognizer*)gestureRecognizer;
- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer;
- (void)outTrayUpdated:(NSNotification *)notif;
@end
