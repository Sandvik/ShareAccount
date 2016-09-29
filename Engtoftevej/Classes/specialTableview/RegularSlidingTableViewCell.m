//
//  RegularSlidingTableViewCell.m
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

#import "RegularSlidingTableViewCell.h"

@implementation RegularSlidingTableViewCell

@synthesize titleLabel = _titleLabel;

#pragma mark -
#pragma mark Creation/Removal Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  self = [super initWithStyle:style reuseIdentifier:identifier];

  if (nil != self) {
//    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, 13, 304, 20)] autorelease];
//    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
//    self.titleLabel.textColor = [UIColor blackColor];
//    self.titleLabel.backgroundColor = [UIColor clearColor];
//    [self.topDrawer addSubview:self.titleLabel];
//      
      super.textLabel.font = [UIFont systemFontOfSize:15];
      super.textLabel.backgroundColor = [UIColor clearColor];
      super.textLabel.opaque = YES;
      super.textLabel.textColor = [UIColor blackColor];
      super.textLabel.highlightedTextColor = [UIColor whiteColor];
      super.textLabel.textAlignment = UITextAlignmentLeft; // default
      [self.topDrawer addSubview:super.textLabel];
      
      
      super.detailTextLabel.font = [UIFont systemFontOfSize:12];
      super.detailTextLabel.backgroundColor = [UIColor clearColor];
      super.detailTextLabel.opaque = YES;
      super.detailTextLabel.textColor = [UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1];
      super.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
      super.detailTextLabel.textAlignment = UITextAlignmentLeft; // default
      
  }

  return self;
}

- (void)dealloc {
  [_titleLabel release];

  _titleLabel = nil;

  [super dealloc];
}

#pragma mark -
#pragma mark JBSlidingTableViewCell Methods

- (void)bottomDrawerWillAppear {
  self.bottomDrawer.backgroundColor = [UIColor lightGrayColor];

  UILabel* bottomDrawerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, 13, 304, 20)] autorelease];
  bottomDrawerLabel.font = [UIFont boldSystemFontOfSize:17];
  bottomDrawerLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
  bottomDrawerLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.75];
  bottomDrawerLabel.shadowOffset = CGSizeMake(0, 1);
  bottomDrawerLabel.backgroundColor = [UIColor clearColor];
  bottomDrawerLabel.text = @"Bottom drawer!";
    
    UIButton *settingsButton = [[UIButton alloc] init];
    settingsButton.frame=CGRectMake(0,0,32,32);
    [settingsButton setBackgroundImage:[UIImage imageNamed: @"Sites-icon.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(quitView:) forControlEvents:UIControlEventTouchUpInside];  
     
  [self.bottomDrawer addSubview:settingsButton];
}

@end
