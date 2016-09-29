//
//  NYKHelpView.m
//  MitNykredit
//
//  Created by Sandvik.
//  Copyright 2011 Nykredit. All rights reserved.
//

#import "NYKHelpView.h"

@implementation NYKHelpView

+ (id)alertViewWithMessage:(NSString *)headline message:(NSString *)message buttons:(NYKAlertViewButtons)buttons callback:(void (^)(NSInteger buttonIndex))callback
{
	return [[self alloc] initWithMessage:headline message:message buttons:buttons callback:callback];
}

- (id)initWithMessage:(NSString *)headline message:(NSString *)message buttons:(NYKAlertViewButtons)buttons callback:(void (^)(NSInteger buttonIndex))callback
{
	if ((self = [super init]))
	{
		_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		_view.backgroundColor = [UIColor clearColor];

		UIView *backgroundView = [[[UIView alloc] initWithFrame:_view.frame] autorelease];
		backgroundView.backgroundColor = [UIColor whiteColor];
		backgroundView.alpha = 0.8;
		[_view addSubview:backgroundView];

		UIImageView *alertBackgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay-bg-pinkodehusker.png"]] autorelease];
		alertBackgroundImageView.frame = CGRectMake(4, 114, 311, 250);
		[_view addSubview:alertBackgroundImageView];
        
        /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         * Horizontal line 
         *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
        UIView *lineView2 =[[UIView alloc] initWithFrame:CGRectMake(20, 300, 275, 1)];
        lineView2.backgroundColor = [UIColor lightGrayColor];//[UIColor colorWithRed:34.0/255.0 green:56.0/255.0 blue:127.0/255.0 alpha:1.0];
        [_view addSubview:lineView2];

        UIView *lineView1 =[[UIView alloc] initWithFrame:CGRectMake(20, 165, 275, 1)];
        lineView1.backgroundColor = [UIColor lightGrayColor];//[UIColor colorWithRed:34.0/255.0 green:56.0/255.0 blue:127.0/255.0 alpha:1.0];
        [_view addSubview:lineView1];
        
        _headline = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 275, 20)];
		_headline.numberOfLines = 0;
		_headline.backgroundColor = [UIColor clearColor];
        _headline.font = [UIFont fontWithName:@"Verdana-Bold" size:14];
		_headline.textColor = [UIColor colorWithRed:34.0/255.0 green:56.0/255.0 blue:127.0/255.0 alpha:1.0];
		_headline.text = headline;
		_headline.textAlignment = UITextAlignmentLeft;
		[_view addSubview:_headline];       
        
		_message = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 275, 200)];
		_message.numberOfLines = 0;
		_message.backgroundColor = [UIColor clearColor];
		_message.font = [UIFont fontWithName:@"Verdana" size:13.0];
		_message.textColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1];//[UIColor colorWithRed:34.0/255.0 green:56.0/255.0 blue:127.0/255.0 alpha:1.0];
		_message.text = message;
		_message.textAlignment = UITextAlignmentLeft;
		[_view addSubview:_message];

		if (buttons == NYKAlertViewButtonsOK){
        
            
			UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
			[button1 setImage:[UIImage imageNamed:@"btn-overlay.png"] forState:UIControlStateNormal];
			[button1 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
			button1.frame = CGRectMake(200, 305, 100, 33);
			button1.tag = 0;
			[_view addSubview:button1];
		}
		else if (buttons == NYKAlertViewButtonsYesNo)
		{
			UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
			[button1 setImage:[UIImage imageNamed:@"overlay-kanp-ja-pinkodehusker.png"] forState:UIControlStateNormal];
			[button1 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
			button1.frame = CGRectMake(38, 195, 111, 43);
			button1.tag = 0;
			
			UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
			[button2 setImage:[UIImage imageNamed:@"overlay-kanp-nej-pinkodehusker.png"] forState:UIControlStateNormal];
			[button2 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
			button2.frame = CGRectMake(170, 195, 111, 43);
			button2.tag = 1;

			[_view addSubview:button1];
			[_view addSubview:button2];
		}

		_callback = [callback copy];
	}
	return self;
}

- (void)show
{
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];

	_view.frame = window.bounds;
	_view.alpha = 0.0;

	[window addSubview:_view];

	id animations = ^{
		_view.alpha = 1.0;
	};
	id completion = ^(BOOL finished) {
		
	};
	[UIView animateWithDuration:0.3 animations:animations completion:completion];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
	id animations = ^{
		_view.alpha = 0.0;
	};
	id completion = ^(BOOL finished) {
		[_view removeFromSuperview];
		_view = nil;
	};
	[UIView animateWithDuration:0.3 animations:animations completion:completion];

	if (_callback)
		_callback(buttonIndex);
}

#pragma mark -
- (void)button:(id)sender
{
	if (![sender isKindOfClass:[UIButton class]])
		return;

	[self dismissWithClickedButtonIndex:((UIButton *)sender).tag animated:YES];
}

#pragma mark -
- (void)dealloc
{
	[_view release];
	[_callback release];

	[super dealloc];
}

@end