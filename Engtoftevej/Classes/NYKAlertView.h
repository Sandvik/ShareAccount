//
//  NYKAlertView.h
//  MitNykredit
//
//  Created by Christian Rasmussen on 16/06/11.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	NYKAlertViewButtonsOK,
	NYKAlertViewButtonsYesNo
} NYKAlertViewButtons;

@interface NYKAlertView : NSObject {
@private
	UIView *_view;
	UILabel *_message;

	void (^_callback)(NSInteger buttonIndex);
}

+ (id)alertViewWithMessage:(NSString *)message buttons:(NYKAlertViewButtons)buttons callback:(void (^)(NSInteger buttonIndex))callback;

- (id)initWithMessage:(NSString *)message buttons:(NYKAlertViewButtons)buttons callback:(void (^)(NSInteger buttonIndex))callback;

- (void)show;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end