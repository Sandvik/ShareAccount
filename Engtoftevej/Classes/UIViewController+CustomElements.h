//
//  UIViewController+CustomElements.h
//  CopenhagenCityHouses
//
//  Created by Sergey on 30.01.12.
//  Copyright (c) 2012 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CustomElements)

- (void)setCustomBackButton;
- (void)setCustomTitle:(NSString*)title;
- (void)back;
- (UIBarButtonItem*)menuBarButton;
- (void)showSideMenu;
- (void)goHomeBtn;
- (UIBarButtonItem*)customBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
- (void)adjustNavigationBarImage;
- (UIBarButtonItem*)backButtonWithTarget:(id)target action:(SEL)action;
- (UIBarButtonItem*)settingsBarButtonWithTarget:(id)target action:(SEL)action;

@end
