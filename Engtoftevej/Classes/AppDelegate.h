#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
    
    UIButton * moneyBtn;
}
@property (nonatomic, retain) UIButton * moneyBtn;


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
- (void) hideTabBar;
- (void) showTabBar;
//- (void)setAppearance;
@end


