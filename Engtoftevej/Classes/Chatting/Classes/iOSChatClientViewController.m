#import "iOSChatClientViewController.h"
#import "AppDataCache.h"
#import "GTMHTTPFetcher.h"
#import "GDataXMLNode.h"
#import "JSON.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];


@implementation iOSChatClientViewController

@synthesize messageText, sendButton;
@synthesize parent;
// The inital loader

- (void)viewDidLoad {
    [super viewDidLoad];

	
    bubbleTable.bubbleDataSource = self;
    
    bubbleTable.snapInterval = 130;
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
	[self getNewMessages];
    
       
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.frame=CGRectMake(0,0,32,32);
    [button2 setBackgroundImage:[UIImage imageNamed: @"green_back.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button2];
    [button2 release];

    
    self.title = @"Chat with the others";
    
    [messageText setDelegate:self];
    [messageText setReturnKeyType:UIReturnKeyDone];
    [messageText addTarget:self
                       action:@selector(sendClicked:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    
   // lastId = 0;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		lastId = 0;
		//chatParser = NULL;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
   
}

- (void)viewDidDisappear:(BOOL)animated{
   

}
- (void)viewDidAppear:(BOOL)animated{
    
     [SharedAppDelegate hideTabBar];
//    
//    if([messages count]>5){
//        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([messages count] - 1) inSection:0];
//        [bubbleTable scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        
//    }
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(timerFired:)
                                           userInfo:nil
                                            repeats:YES];

    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCreateViewNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    //BEFORE DOING SO CHECK THAT TIMER MUST NOT BE ALREADY INVALIDATED
    [timer invalidate];
    timer = nil;
}



- (void)dealloc {
    [super dealloc];
}

- (IBAction)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Getting the message

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [messages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [messages objectAtIndex:row];
}

-(void)getNewMessages{
    
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/messages.php?regnskabsid='%d'&past='%d'",[AppDataCache sharedAppDataSource].currentRegnskabsID,
                       lastId];
    [urlStr appendString:mytmp];
    NSLog(@"urlStr %@", urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    //    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    NSDateFormatter *dateFormatterTimeStampShort =[[NSDateFormatter alloc]init];
    [dateFormatterTimeStampShort setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error != nil) {
            // Do your error handling logic
            
            NSString *msg = NSLocalizedString(@"Connection Error",
                                              @"The application encountered a connection error, please try again.");
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
        else {
            // Do your logic and the business logic ends up creating an array which is then parsed to the block
            
            NSString *jsonString = [[[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]autorelease];
            NSLog(@"SpendingData %@", jsonString);
            
            NSDictionary *json = [jsonString JSONValue];
            NSString *msgAdded;
            NSString *msgUser;
            NSString *msgText;
            int msgId;
            [messages removeAllObjects];
            if ( messages == nil ){
                messages = [[NSMutableArray alloc] init];
                
            }
            for (NSDictionary *status in json){
                NSDate *date = [dateFormatterTimeStampShort dateFromString:[status valueForKey:@"added"]];
                
                NSLog(@"%@",[status valueForKey:@"added"]);
                msgAdded = [status valueForKey:@"added"];
                msgId = [[status valueForKey:@"id"]intValue];
                msgUser = [status valueForKey:@"user"];
                msgText = [status valueForKey:@"message"];
                
//                [messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgAdded,@"added",msgUser,@"user",msgText,@"text",nil]];
                
               // [NSString stringWithFormat:@"(%@) %@",added]
                if ([msgUser isEqualToString:[AppDataCache sharedAppDataSource].currentUsername]) {
                    [messages addObject: [NSBubbleData dataWithText:[NSString stringWithFormat:@"Mig: %@",msgText] andDate:date andType:BubbleTypeMine]];
                    
                    
                }else{
                    
                    //NSString *txt = @"hi my friends!"
                    msgUser = [msgUser stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[msgUser substringToIndex:1] uppercaseString]];
                    
                    [messages addObject: [NSBubbleData dataWithText:[NSString stringWithFormat:@"%@: %@",msgUser,msgText] andDate:date andType:BubbleTypeSomeoneElse]];
                
                }
            }        
            
            [bubbleTable reloadData];
            
            
            
            NSLog(@"%@",messages);
            //[messageList reloadData];
            
            if ([messages count] >0) {
                // First figure out how many sections there are
                NSInteger lastSectionIndex = [bubbleTable numberOfSections] - 1;
                
                // Then grab the number of rows in the last section
                NSInteger lastRowIndex = [bubbleTable numberOfRowsInSection:lastSectionIndex] - 1;
                
                // Now just construct the index path
                NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                
                
                
                [bubbleTable scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                
            }
                   
        }
    }];
    
    [dateFormatterTimeStampShort release];
}


//
//- (void)getNewMessages {
//
//	NSString *url = [NSString stringWithFormat:@"http://www.sandviks.dk/messages.php?past=%d&t=%ld",
//					 lastId, time(0) ];
//
//	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
//	[request setURL:[NSURL URLWithString:url]];
//	[request setHTTPMethod:@"GET"];
//
//    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
//    if (conn)
//    {
//        receivedData = [[NSMutableData data] retain];
//    }
//    else
//    {
//    }
//}

-(void)timerFired:(NSTimer *) theTimer
{
    NSLog(@"timerFired @ %@", [theTimer fireDate]);
    [self getNewMessages];
}

//- (void)timerCallback {
//	[self getNewMessages];
//}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    [receivedData setLength:0];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    [receivedData appendData:data];
//}

//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//	if (chatParser)
//        [chatParser release];
//
//	if ( messages == nil )
//		messages = [[NSMutableArray alloc] init];
//
//	chatParser = [[NSXMLParser alloc] initWithData:receivedData];
//	[chatParser setDelegate:self];
//	[chatParser parse];
//
//	[receivedData release];
//
//	[messageList reloadData];
//
//	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
//											[self methodSignatureForSelector: @selector(timerCallback)]];
//	[invocation setTarget:self];
//	[invocation setSelector:@selector(timerCallback)];
//	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 invocation:invocation repeats:NO];
//}

// Parsing the XML message list

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//	if ( [elementName isEqualToString:@"message"] ) {
//		msgAdded = [[attributeDict objectForKey:@"added"] retain];
//		msgId = [[attributeDict objectForKey:@"id"] intValue];
//		msgUser = [[NSMutableString alloc] init];
//		msgText = [[NSMutableString alloc] init];
//		inUser = NO;
//		inText = NO;
//	}
//	if ( [elementName isEqualToString:@"user"] ) {
//		inUser = YES;
//	}
//	if ( [elementName isEqualToString:@"text"] ) {
//		inText = YES;
//	}
//}
//
//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
//	if ( inUser ) {
//		[msgUser appendString:string];
//	}
//	if ( inText ) {
//		[msgText appendString:string];
//	}
//}
//
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//	if ( [elementName isEqualToString:@"message"] ) {
//		[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgAdded,@"added",msgUser,@"user",msgText,@"text",nil]];
//
//		lastId = msgId;
//
//		[msgAdded release];
//		[msgUser release];
//		[msgText release];
//	}
//	if ( [elementName isEqualToString:@"user"] ) {
//		inUser = NO;
//	}
//	if ( [elementName isEqualToString:@"text"] ) {
//		inText = NO;
//	}
//}

// Driving The Table View

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:(NSInteger)section {
//	return ( messages == nil ) ? 0 : [messages count];
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *itemAtIndex = (NSDictionary *)[messages objectAtIndex:indexPath.row];
//    //	UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
//    //	textLabel.text = [itemAtIndex objectForKey:@"text"];
//    //	UILabel *userLabel = (UILabel *)[cell viewWithTag:2];
//    //	userLabel.text = [itemAtIndex objectForKey:@"user"];
//    
//    NSString *text = [itemAtIndex objectForKey:@"text"];
//    
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
//    
//    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    
//    CGFloat height = MAX(size.height, 44.0f);
//    
//    return height + (CELL_CONTENT_MARGIN * 2);
//    
//    
//	//return 50;
//}

//- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//	UITableViewCell *cell = (UITableViewCell *)[self.messageList dequeueReusableCellWithIdentifier:@"ChatListItem"];
//	UILabel *label = nil;
//    UILabel *userlabel = nil;
//    UILabel *timelabel = nil;
//    
//    
//    if (cell == nil) {
//    	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatListItem" owner:self options:nil];
//		cell = (UITableViewCell *)[nib objectAtIndex:0];
//        
//        label = [[UILabel alloc] initWithFrame:CGRectZero];
//        [label setLineBreakMode:UILineBreakModeWordWrap];
//        [label setMinimumFontSize:FONT_SIZE];
//        [label setNumberOfLines:0];
//        [label setFont:[UIFont systemFontOfSize:13]];
//        [label setTag:1];
//        [label setBackgroundColor:[UIColor clearColor]];
//        
//        NSString *blue = @"324F85";
//        int b =0;
//        sscanf([blue UTF8String],"%x",&b);
//        UIColor* btnColor = UIColorFromRGB(b);
//        label.textColor = btnColor;
//        // [[label layer] setBorderWidth:2.0f];
//        
//        [[cell contentView] addSubview:label];
//        
//        userlabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [userlabel setLineBreakMode:UILineBreakModeWordWrap];
//        [userlabel setMinimumFontSize:FONT_SIZE];
//        [userlabel setNumberOfLines:1];
//        [userlabel setFont:[UIFont boldSystemFontOfSize:12]];
//        [userlabel setTag:2];
//         [userlabel setBackgroundColor:[UIColor clearColor]];
//        userlabel.textColor = btnColor;
//        // [[label layer] setBorderWidth:2.0f];
//        
//        [[cell contentView] addSubview:userlabel];
//        
//        timelabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [timelabel setLineBreakMode:UILineBreakModeWordWrap];
//        [timelabel setMinimumFontSize:10];
//        [timelabel setNumberOfLines:1];
//        [timelabel setFont:[UIFont italicSystemFontOfSize:10]];
//        timelabel.textColor = [UIColor darkGrayColor];
//        [timelabel setTag:3];
//        [timelabel setBackgroundColor:[UIColor clearColor]];
//        // [[label layer] setBorderWidth:2.0f];
//        
//        [[cell contentView] addSubview:timelabel];
//        
//
//        
//	}
//	
//    
//    NSDictionary *itemAtIndex = (NSDictionary *)[messages objectAtIndex:indexPath.row];
//    //	UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
//    //	textLabel.text = [itemAtIndex objectForKey:@"text"];
//    //	UILabel *userLabel = (UILabel *)[cell viewWithTag:2];
//    //	userLabel.text = [itemAtIndex objectForKey:@"user"];
//    
//    NSString *text = [itemAtIndex objectForKey:@"text"];
//    
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
//    
//    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    
//    if (!label)
//        label = (UILabel*)[cell viewWithTag:1];
//    
//    if (!userlabel)
//        userlabel = (UILabel*)[cell viewWithTag:2];
//    
//    [label setText:text];
//    [label setFrame:CGRectMake(2, 12, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
//    
//     NSString *user = [itemAtIndex objectForKey:@"user"];
//    [userlabel setText:user];
//    [userlabel setFrame:CGRectMake(2, 0,100, 20)];
//    
//    NSString *added = [itemAtIndex objectForKey:@"added"];
//   
//    
//    NSString *timePsot = [NSString stringWithFormat:@"Posted %@",added];
//    [timelabel setText:timePsot];
//    [timelabel setFrame:CGRectMake(165, 0,200, 20)];
//    
//    UIImageView *myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"konto-bg-2.png"]];
//    
//    [cell setBackgroundView:myImageView];
//    cell.userInteractionEnabled = NO;
//    
//    return cell;
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//}
//
// Sending the message to the server

- (IBAction)sendClicked:(id)sender {
	[messageText resignFirstResponder];
	if ( [messageText.text length] > 0 ) {
		//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
        NSMutableString *urlStr =[[NSMutableString alloc] init];
        NSString *url = [NSString stringWithFormat:@"http://www.sandviks.dk/add.php?user='%@'&message='%@'&regnskabsid='%d'",[AppDataCache sharedAppDataSource].currentUsername,
                           [messageText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [AppDataCache sharedAppDataSource].currentRegnskabsID ];
        [urlStr appendString:url];
        NSLog(@"urlStr %@", urlStr);      
        
        
		
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		[request setURL:[NSURL URLWithString:urlStr]];
		[request setHTTPMethod:@"POST"];
		
		
		
		NSHTTPURLResponse *response = nil;
		NSError *error = [[[NSError alloc] init] autorelease];
		[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		[self getNewMessages];
	}
	
	messageText.text = @"";
}



@end
