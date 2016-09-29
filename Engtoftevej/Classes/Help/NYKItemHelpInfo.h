//
//  NYKItemHelpInfo.h
//  UIXOverlayController
//
//  Created by Nykredit DK on 12/19/11.
//  Copyright (c) 2011 Kickstand Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NYKItemHelpInfo : NSObject{
    CGPoint infoItemPostion;
    NSString *infoKey;
    NSInteger viewTag;
}
@property (nonatomic) NSInteger viewTag;
@property (nonatomic, retain) NSString *infoKey;
@property (nonatomic) CGPoint infoItemPostion;
@end
