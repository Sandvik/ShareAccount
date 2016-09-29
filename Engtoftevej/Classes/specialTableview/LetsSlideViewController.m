//
//  LetsSlideViewController.m
//  LetsSlide
//
//  Copyright 2010 Jake Boxer
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "LetsSlideViewController.h"
#import "RegularSlidingTableViewCell.h"
#import "AppDataCache.h"
#import "NYKGeneralAccount.h"
#import "AccountUserSettingController.h"
#import "Utilities.h"

#import "GTMHTTPFetcher.h"
#import "GDataXMLNode.h"
#import "JSON.h"

@interface LetsSlideViewController ()

@property (nonatomic, readonly) JBSlidingTableViewCell* openedCell;
@property (nonatomic, retain) NSIndexPath* openedCellIndexPath;
@property (nonatomic, copy) NSArray* regularCellStrings;

- (void)closeOpenedCell;

@end

@implementation LetsSlideViewController

@synthesize openedCellIndexPath = _openedCellIndexPath;
@synthesize regularCellStrings = _regularCellStrings;
@synthesize tableView = _tableView;
@synthesize resLabel;
@synthesize switch1;

#pragma mark -
#pragma mark Creation/Removal Methods

- (void)viewDidLoad {
    self.title=@"People";
    _openedCellIndexPath = nil;
    
    NSLog(@"%@",[AppDataCache sharedAppDataSource].peopleList);
    self.regularCellStrings = [AppDataCache sharedAppDataSource].peopleList;//NSArray arrayWithObjects:@"Person 1", @"Person 2",@"Person 3",@"Person 4", nil];
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.frame=CGRectMake(0,0,32,32);
    [button2 setBackgroundImage:[UIImage imageNamed: @"green_back.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button2];
    [button2 release];
    
    if ([[AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige isEqualToString:@"LIGE"]) {
        [switch1 setOn:YES];
        resLabel.text = @"Everyone pays the same amount";
    }else{
        [switch1 setOn:NO];
        resLabel.text = @"Settings determine the amount";
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [SharedAppDelegate hideTabBar];
    self.regularCellStrings = [AppDataCache sharedAppDataSource].peopleList;//NSArray arrayWithObjects:@"Person 1", @"Person 2",@"Person 3",@"Person 4", nil];
    [_tableView reloadData];
    if (!switch1.on){
        [Utilities checkPercentage];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCreateViewNotification" object:nil];
}


- (IBAction) toggleEnabledTextForSwitch1onSomeLabel: (id) sender {
	if (switch1.on){
        resLabel.text = @"Everyone pays the same amount";
        
    }
    else{
        resLabel.text = @"Settings determine the amount";
        [Utilities checkPercentage];
        
    }
    
    
    [_tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        
	}
	else if (buttonIndex == 1)
	{
		// No
	}
}


- (void)dealloc {
    [_openedCellIndexPath release];
    [_tableView release];
    [resLabel release];
    [switch1 release];
    
    _openedCellIndexPath = nil;
    _tableView = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

- (JBSlidingTableViewCell*)openedCell {
    JBSlidingTableViewCell* cell;
    
    if (nil == self.openedCellIndexPath) {
        cell = nil;
    } else {
        cell = (JBSlidingTableViewCell*)[self.tableView cellForRowAtIndexPath:self.openedCellIndexPath];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Private Methods

- (void)closeOpenedCell {
    [self.openedCell closeDrawer];
    self.openedCellIndexPath = nil;
}

- (IBAction)backBtn:(id)sender
{
    //Update afregningsmodel hvis den er anderledes end da vi kom ind
    
    //[AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige
    
    if (switch1.on){ //SKAL VÆRE LIGE
        //resLabel.text = @"Everyone pays the same amount";
        if ([[AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige isEqualToString:@"ULIGE"]) {
            //Vi skal update på server så den står som LIGE
            [self updateFordelingiRegnskab:@"NEJ"];
        }
        
    }
    else{//SKAL VÆRE ULIGE
        //resLabel.text = @"Settings determine the amount";
        if ([[AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige isEqualToString:@"LIGE"]) {
            //Vi skal update på server så den står som ULIGE
            [self updateFordelingiRegnskab:@"JA"];
        }
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)updateFordelingiRegnskab:(NSString*)afregnIndividuel{
    NSMutableString *urlStr =[[NSMutableString alloc] init];
    NSString *mytmp = [NSString stringWithFormat:@"http://www.sandviks.dk/updateAfregningsModel4Regnskab.php?regnskabsid='%d'&afregnIndividuel='%@'",[AppDataCache sharedAppDataSource].currentRegnskabsID,afregnIndividuel];
    [urlStr appendString:mytmp];
    ////NSLog(@"urlStr %@", urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"da" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"abc" forHTTPHeaderField:@"X-App-Key"];
    [request setValue:@"1.0" forHTTPHeaderField:@"X-Service-Generation"];
    
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
            if ([afregnIndividuel isEqualToString:@"JA"]) {
                [AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige=@"ULIGE";
            }else{
                [AppDataCache sharedAppDataSource].regnskabsAfregnesLigeEllerUlige=@"LIGE";
            }
        }
    }];
    
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    [self closeOpenedCell];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* CellIdentifier = @"Identifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[RegularSlidingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NYKGeneralAccount *person=[self.regularCellStrings objectAtIndex:indexPath.row];
    
    NSLog(@"%@",person);
    NSString *tmpText =@"";
    if (switch1.on) {
        
        tmpText =[NSString stringWithFormat:@"%@", person.objectName];
    }
    else{
        tmpText =[NSString stringWithFormat:@"%@. Percentage split %.2f%%", person.objectName,person.fordeling];
    }
    ((RegularSlidingTableViewCell*)cell).textLabel.text = tmpText;//[NSString stringWithFormat:@"%@. Percentage split %.2f%%", person.objectName,person.fordeling];
    
    //percentage split
    //NYKGeneralAccount *payment
    int counter =0;
    for(NYKGeneralAccount *ext in [AppDataCache sharedAppDataSource].accounts){
        if ([ext.objectName isEqualToString:person.objectName]) {
            counter +=1;
        }
    }
    
    ((RegularSlidingTableViewCell*)cell).detailTextLabel.text =[NSString stringWithFormat:@"Number of entries %d:", counter];
    
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"konto-bg-2.png"]];
    cell.imageView.image = [UIImage imageNamed:@"person.png"];
    [cell setBackgroundView:myImageView];
    //    cell.userInteractionEnabled = NO;
    //    cell.userInteractionEnabled = NO;
    //
    if (switch1.on) {
        cell.accessoryView = UITableViewCellAccessoryNone;
    }
    else{
        UIImage *image = [UIImage imageNamed:@"setting.png"]; //or wherever you take your image from
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        cell.accessoryView = imageView;
        [imageView release];
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.regularCellStrings count];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (!switch1.on) {
        
        
        NYKGeneralAccount *general = [[AppDataCache sharedAppDataSource].peopleList objectAtIndex:indexPath.row];
        
        AccountUserSettingController *detailViewController = [[AccountUserSettingController alloc] initWithNibName:@"accountUserSetting" bundle:nil];
        detailViewController.user=general;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
        
        [SharedAppDelegate hideTabBar];
    }
    
}

@end
