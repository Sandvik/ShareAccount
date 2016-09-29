//
//  UIXOverlayControllerViewController.m
//  UIXOverlayController
//
//  Created by Guy Umbright on 5/29/11.
//  Copyright 2011 Kickstand Software. All rights reserved.
//

#import "UIXOverlayControllerViewController.h"
#import "DialogContentViewController.h"
#import "NYKItemHelpInfo.h"
@implementation UIXOverlayControllerViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*Denne metode skal være på alle de controllers hvor man ønsker hjælpo. Denne skal udfyldes som nedenstående med info om CGPoint om elementet hvor hjælpeknappen skal være
 */
- (IBAction) showHelpOverlay:(id) sender{
    overlay = [[UIXOverlayController alloc] init];
    overlay.dismissUponTouchMask = NO;
    
    DialogContentViewController* vc = [[DialogContentViewController alloc] init];
    
    NSMutableArray *overVievArray = [[NSMutableArray alloc] init];
    
    //The first button which ve want help about
    UIButton *random = (UIButton *)[self.view viewWithTag:3];    
    CGPoint fr =random.frame.origin;
    NSLog(@"%@",NSStringFromCGPoint(fr));        
    //Sets all UIbuttons in array/dict on object
    NYKItemHelpInfo *nykInfo = [[NYKItemHelpInfo alloc] init]; 
    nykInfo.infoItemPostion=fr;
    nykInfo.infoKey=@"HelpButton";
    [overVievArray addObject:nykInfo];
    
    UIButton *random2 = (UIButton *)[self.view viewWithTag:4];    
     CGPoint fr2 =random2.frame.origin;
    NSLog(@"%@",NSStringFromCGPoint(fr2));        
    //Sets all UIbuttons in array/dict on object
    NYKItemHelpInfo *nykInfo2 = [[NYKItemHelpInfo alloc] init]; 
    nykInfo2.infoItemPostion=fr2;
    nykInfo2.infoKey=@"InfoButtonErer";
    [overVievArray addObject:nykInfo2];
    
    UIButton *random3 = (UIButton *)[self.view viewWithTag:5];    
     CGPoint fr3 =random3.frame.origin;
    NSLog(@"%@",NSStringFromCGPoint(fr3));        
    NYKItemHelpInfo *nykInfo3 = [[NYKItemHelpInfo alloc] init]; 
    nykInfo3.infoItemPostion=fr3;
    nykInfo3.infoKey=@"CallButton232";
    [overVievArray addObject:nykInfo3];
    
    UILabel *random4 = (UILabel *)[self.view viewWithTag:6];    
    CGPoint fr4 =random4.frame.origin;
    NSLog(@"%@",NSStringFromCGPoint(fr4));        
    NYKItemHelpInfo *nykInfo4 = [[NYKItemHelpInfo alloc] init]; 
    nykInfo4.infoItemPostion=fr4;
    nykInfo4.infoKey=@"CallLbl232";
    [overVievArray addObject:nykInfo4];    
    
    vc.muteArray =overVievArray;
    [overVievArray release];
    [overlay presentOverlayOnView:self.view withContent:vc animated:DIALOG_ANIMATED];
}

- (void) overlayRemoved:(UIXOverlayController*) overlayController
{
    [overlay release];
    overlay = nil;
}


@end
