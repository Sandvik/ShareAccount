//
//  NYKiPadAccountTileView.m
//  MitNykredit
//
//  Created by Jens Willy Johannsen on 31-01-12.
//  Copyright (c) 2012 Nykredit. All rights reserved.
//

#import "NYKiPadOuttrayTileView.h"
#import "MBProgressHUD.h"


extern NSString* const kTileSettingAccountNumber;	// Is declared in NYKiPadSpendingOverviewTileView.m
extern NSString* const kTileSettingHashedAccount;	// Is declared in NYKiPadSpendingOverviewTileView.m

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];

@implementation NYKiPadOuttrayTileView
@synthesize contentView;
@synthesize balanceLabel,totalLabel;
@synthesize transactionsView;
@synthesize accountNameLabel;
@synthesize dividerView,dividerViewBalance;


- (void)dealloc {
    remoteServiceController.delegate = nil;
	[remoteServiceController release];
	[contentView release];
	[balanceLabel release];
    [totalLabel release];
	[transactionsView release];
    [dividerView release];
    [super dealloc];
}

- (id)initWithString:(NSString*)text
{
	if( (self = [super initWithFrame:CGRectZero]) )
	{
		// Set currency
		// Load XIB
		[[NSBundle mainBundle] loadNibNamed:@"NYKiPadOuttrayTileView" owner:self options:nil];
		
		// Set frame size
		self.clipsToBounds = NO;
		CGRect frame = self.frame;
		frame.size = self.contentView.bounds.size;
		self.frame = frame;
		[self addSubview:self.contentView];
		
		// Attach gesture recognizers
		UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:recognizer];
		[recognizer release];
		
		recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
		[self addGestureRecognizer:recognizer];
		[recognizer release];
	}
    
    remoteServiceController =[[RemoteController alloc]init]; 
	[MBProgressHUD showHUDAddedTo:self animated:YES];
    
    //gemmer disse hvis der flere end 5
    balanceLabel.hidden=YES;
    totalLabel.hidden=YES;
    [self listEnvelopContentsOuttray];
	
    // Register observer for when download of data is complete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outTrayUpdated:) name:@"NOTIF_DataSendToOuttray" object:nil]; 
    
    
	return self;
}

- (void)outTrayUpdated:(NSNotification *)notif{
    DLog(@"Received Notification - Data has been downloaded");
    //remomve all subvievs
    for (UIView *viw in [transactionsView subviews]) {
        [viw removeFromSuperview];
    }
    [self listEnvelopContentsOuttray];
    
}


#pragma mark - RemoteServiceController methods


//Fetch stuff from Outtray
-(void)listEnvelopContentsOuttray{
    
    NSURL *url; 
    
    
    NSMutableString *urlStr = [[[AppDataCache sharedAppDataSource] baseRestURL] mutableCopy];  
    //[urlStr appendString:[RemoteServiceStatus sharedStatus].customer];
    [urlStr appendString:@"/envelopes/outTray/contents"];
    url = [NSURL URLWithString:urlStr]; 
    DLog(@"%@",url);
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Nykredit Iphone user" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
    
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest: request];
    [fetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self animated:YES];
        
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
            
            
            //if ([AppDataCache sharedAppDataSource].isRestCommunication) {
            if([remoteServiceController isValidJsonResponseFromFetcher:fetcher data:retrievedData caller:kAppDataCacheListStoredTransfersStatusCode]){
                
                OutTrayResponse *response = [SmartPhoneResponseFactory listEnvelopContentsOuttrayResponseFromJson:retrievedData];
                //                DLog(@"%@",response.payments);
                [AppDataCache sharedAppDataSource].payments = response.payments; //save to cache
                
                // Sort the transactions by timestamp
                
                // Create static number formatter (so we don't have to initialize and configure every time)
                static NSNumberFormatter *numberFormatter = nil;
                if( numberFormatter == nil )
                {
                    numberFormatter = [[NSNumberFormatter alloc] init];
                    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"da_DA"];
                    [numberFormatter setLocale:locale];
                    [numberFormatter setCurrencySymbol:@""];
                    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [locale release];
                }
                NSDateFormatter *dateFormat = [[[NSDateFormatter alloc]init]autorelease];
                [dateFormat setDateFormat:@"dd-MM-yyyy"];
                
                CGFloat maxY = 0;
                accountNameLabel.text=[NSString stringWithFormat:@"(%d)",[response.payments count]];
                
                // Iterate the transactions (5 or all transactions – whichever is lowest)
                int showNumber =5;
                if ([response.payments count]==0) {
                    showNumber=0;
                    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, maxY, 0, 0 )];
                    dateLabel.backgroundColor = [UIColor clearColor];
                    dateLabel.font = [UIFont fontWithName:@"FoundryFormSans-Book" size:18];
                    dateLabel.textAlignment = UITextAlignmentRight;
                    dateLabel.textColor = RGB(8, 24, 109);
                    dateLabel.shadowColor = [UIColor whiteColor];
                    dateLabel.shadowOffset = CGSizeMake(0, 1);
                    dateLabel.text=@"Din udbakke er tom";
                    [dateLabel sizeToFit];
                    [transactionsView addSubview:dateLabel];
                    dividerViewBalance.hidden=YES;               
                    for (UIGestureRecognizer *gesture in[self gestureRecognizers]) {
                        [self removeGestureRecognizer:gesture];
                    }
                }else {
                    NYKPayment *transactionTmp;
                    for( int i=0; i < MIN(showNumber, [response.payments count] ); i++ )
                    {
                        NYKPayment *transaction = [response.payments objectAtIndex:i];
                        
                        DLog(@"%@",transaction);
                        // Date
                        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, maxY, 0, 0 )];
                        dateLabel.backgroundColor = [UIColor clearColor];
                        dateLabel.font = [UIFont fontWithName:@"FoundryFormSans-Book" size:18];
                        dateLabel.textAlignment = UITextAlignmentRight;
                        dateLabel.textColor = RGB(8, 24, 109);
                        dateLabel.shadowColor = [UIColor whiteColor];
                        dateLabel.shadowOffset = CGSizeMake(0, 1);
                        if (transaction.shadowTransferOrPaymentDate!=nil) {
                            dateLabel.text=@"Snarest muligt";
                        }else{
                            
                                dateLabel.text = [dateFormat stringFromDate:transaction.transferOrPaymentDate];
                           

                        }
                        [dateLabel sizeToFit];
                        [transactionsView addSubview:dateLabel];
                        //[dateLabel release];
                        
                        // Amount
                        UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, maxY, 0, 0 )];
                        amountLabel.backgroundColor = [UIColor clearColor];
                        amountLabel.font = [UIFont fontWithName:@"FoundryFormSans-Book" size:18];
                        amountLabel.textAlignment = UITextAlignmentRight;
                        
                        NSString *blue = @"ED1C24";
                        int b =0;
                        sscanf([blue UTF8String],"%x",&b);
                        UIColor* btnColor = UIColorFromRGB(b);
                        
//                        NSComparisonResult result = [transaction.amount compare:[NSDecimalNumber zero]];
//                        if (result ==  NSOrderedAscending) {
//                            blue = @"ED1C24";
//                            b=0;
//                            sscanf([blue UTF8String],"%x",&b);
//                            btnColor = UIColorFromRGB(b);
//                        }
//                        else {
//                            blue = @"22387f";
//                            b=0;
//                            sscanf([blue UTF8String],"%x",&b);
//                            btnColor = UIColorFromRGB(b);
//                        }
                        
                        amountLabel.textColor = btnColor;
                        //amountLabel.textColor = RGB(8, 24, 109);
                        amountLabel.shadowColor = [UIColor whiteColor];
                        amountLabel.shadowOffset = CGSizeMake(0, 1);
                        //Sætter værdi med minus foran så det ligner det er et outbound beløb
                        amountLabel.text = [NSString stringWithFormat:@"-%@",[numberFormatter stringFromNumber:transaction.amount]];//[numberFormatter stringFromNumber:transaction.amount];
                        [amountLabel sizeToFit];
                        CGRect frame = amountLabel.frame;
                        frame.origin.x = transactionsView.bounds.size.width - frame.size.width + 5;
                        amountLabel.frame = frame;
                        [transactionsView addSubview:amountLabel];
                        //[amountLabel release];
                        
                        // Description
                        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake( 2, maxY+20, 0, 0 )];
                        descriptionLabel.lineBreakMode = UILineBreakModeTailTruncation;
                        descriptionLabel.backgroundColor = [UIColor clearColor];
                        descriptionLabel.font = [UIFont fontWithName:@"FoundryFormSans-Book" size:18];
                        descriptionLabel.textColor = RGB(102, 113, 140);
                        descriptionLabel.shadowColor = [UIColor whiteColor];
                        descriptionLabel.shadowOffset = CGSizeMake(0, 1);
                        
                        if ([transaction.type isEqualToString:@"transfer"]) {
                            descriptionLabel.text = [Utilities formatAccountnumber:transaction.toAccountNumber];
                        }
                        else{
                            descriptionLabel.text = transaction.creditorName;
                        }                    
                        
                        [descriptionLabel sizeToFit];
                        
                        // Make sure the text doesn't overlap the amount
                        if( CGRectGetMaxX( descriptionLabel.frame ) > amountLabel.frame.origin.x )
                        {
                            CGRect frame = descriptionLabel.frame;
                            frame.size.width = amountLabel.frame.origin.x - frame.origin.x - 2;
                            descriptionLabel.frame = frame;
                        }
                        
                        [transactionsView addSubview:descriptionLabel];
                       // [descriptionLabel release];
//                        DLog(@"%@",[transactionTmp.transferOrPaymentDate timeIntervalSinceDate:transaction.transferOrPaymentDate]);
                        
                        if ( transactionTmp.transferOrPaymentDate != nil && transaction.transferOrPaymentDate != nil && [transactionTmp.transferOrPaymentDate timeIntervalSinceDate:transaction.transferOrPaymentDate]>86400) {
                            dividerView = [[UIView alloc]initWithFrame:CGRectMake( 2, maxY+30, 50, 10 )];
                            dividerView.backgroundColor=[UIColor yellowColor];
                            [transactionsView addSubview:descriptionLabel];
                        }else{
                            transactionTmp = transaction;
                        }
                        
                        maxY = CGRectGetMaxY( descriptionLabel.frame ) + 4;
                    }	// end-for transactions
                    
                    //Calciúlate whole amount: Vises kun hvis max antallet er lige med antallet af alle items i udbakke
                    if (showNumber == [response.payments count]) {
                        balanceLabel.hidden=NO;
                        totalLabel.hidden=NO;
                        NSDecimalNumber *amountIalt = [NSDecimalNumber zero];
                        for( int i=0; i <[response.payments count]; i++ )
                        {
                            NYKPayment *transaction = [response.payments objectAtIndex:i];
                            NSDecimalNumber *amountLo = transaction.amount;
                            amountIalt = [amountIalt decimalNumberByAdding:amountLo];
                        }  
                        balanceLabel.text=[numberFormatter stringFromNumber:amountIalt];
                    }//Don't show the label
                    else{
                        balanceLabel.hidden=YES;
                        totalLabel.hidden=YES;
                    }                   
                }
                // Set size of transactionsView
                CGRect frame = transactionsView.frame;
                frame.size.height = maxY;
                transactionsView.frame = frame;
                
                // Adjust own frame
                frame = self.frame;
                frame.size.height = CGRectGetMaxY( transactionsView.frame ) + 60;
                self.frame = frame;
                
                // Tell parent that our frame has changed
                [_rootViewController tileFrameDidChange:self];
            }
        }
    }];          
}


#pragma mark - Other methods

- (void)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale( 0.95, 0.95 );
    
	[UIView animateWithDuration:0.1 animations:^{
		// Scale in
		self.transform = scaleTransform;
	} completion:^(BOOL finished) {
		// When done: scale out again
		[UIView animateWithDuration:0.1 animations:^{
			self.transform = CGAffineTransformIdentity;
		} completion:^(BOOL finished) {
			// And when done with scaling out: pass the action to the controller
         	
		}];
		[_rootViewController clickedOuttrayTile:self];
	}];
	
    //	[self performSelector:<#(SEL)#> withObject:<#(id)#> afterDelay:<#(NSTimeInterval)#>
	
    
}

- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer
{
	if( gestureRecognizer.state == UIGestureRecognizerStateBegan )
	{
		self.superview.clipsToBounds = NO;
		self.clipsToBounds = NO;
	}
	
	if( gestureRecognizer.state == UIGestureRecognizerStateChanged )
	{
		// Have we pinched far enough apart?
		if( /* gestureRecognizer.scale <= 1.2 && */ gestureRecognizer.scale >= 1.0 )
		{
			// Yes: scale out (don't worry: it won't continue scaling out since the scaleTransform is based on actual size values)
			CGFloat scale = 1 + (gestureRecognizer.scale-1) * 0.4;
			CGAffineTransform scaleTransform = CGAffineTransformMakeScale( scale, scale );
            
			[UIView animateWithDuration:0.1 animations:^{
				self.transform = scaleTransform;
			}];
		}
	}
	
	if( gestureRecognizer.state == UIGestureRecognizerStateEnded )
	{
		self.clipsToBounds = YES;
		self.superview.clipsToBounds = YES;
        
		// Gesture ends: if we have pinched far enough apart we'll pass the action to the controller and scale in non-animatedly
		if( gestureRecognizer.scale >= 1.2 )
		{
			[_rootViewController clickedOuttrayTile:self];
			self.transform = CGAffineTransformIdentity;
		}
		else
		{
			// Not pinched out enough: scale back in
			[UIView animateWithDuration:0.1 animations:^{
				self.transform = CGAffineTransformIdentity;
			}];
		}
	}
}

@end
