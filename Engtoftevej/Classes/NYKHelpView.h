//
//  NYKHelpView.h
//  MitNykredit
//
//  Created by Sandvik.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYKAlertView.h"
//typedef enum {
//	NYKAlertViewButtonsOK,
//	NYKAlertViewButtonsYesNo
//} NYKAlertViewButtons;

@interface NYKHelpView : NSObject {
@private
	UIView *_view;
	UILabel *_message;
    UILabel *_headline;

	void (^_callback)(NSInteger buttonIndex);
}

+ (id)alertViewWithMessage:(NSString *)headline message:(NSString *)message buttons:(NYKAlertViewButtons)buttons callback:(void (^)(NSInteger buttonIndex))callback;

- (id)initWithMessage:(NSString *)headline message:(NSString *)message buttons:(NYKAlertViewButtons)buttons callback:(void (^)(NSInteger buttonIndex))callback;

- (void)show;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end