#import <UIKit/UIKit.h>
#import "BrowseViewController.h"
#import "UIBubbleTableViewDataSource.h"

@class UIBubbleTableView;

@interface iOSChatClientViewController : UIViewController <UIBubbleTableViewDataSource,UITextFieldDelegate>	{
	IBOutlet UITextField *messageText;
	IBOutlet UIButton *sendButton;
	
    IBOutlet UIBubbleTableView *bubbleTable;
	int lastId;
	
	NSMutableData *receivedData;
	
	NSMutableArray *messages;
	
	NSTimer *timer;
	BrowseViewController *parent;
    
    //IBOutlet UIBubbleTableView *bubbleTable;
    
    //NSMutableArray *bubbleData;
	
}
@property (nonatomic,assign) BrowseViewController *parent;
@property (nonatomic,retain) UITextField *messageText;
@property (nonatomic,retain) UIButton *sendButton;
//@property (nonatomic,retain) UITableView *messageList;

- (IBAction)sendClicked:(id)sender;
- (IBAction)backBtn:(id)sender;
@end

